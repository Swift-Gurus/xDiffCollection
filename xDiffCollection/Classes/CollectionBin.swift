//
//  CollectionBin.swift
//  CollectionTest
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 aldo. All rights reserved.
//

import Foundation
import SwiftyCollection

public typealias CollectionFilter<T> = (T) -> Bool
public typealias CollectionSort<T> = (T,T) -> Bool

public struct CollectionBin<T, Backstorage: RangeReplaceableCollection>: Collection where Backstorage.Element == T {
    
    public typealias Index = Backstorage.Index
    public typealias Element = T
    public var startIndex: Backstorage.Index { return _backstorage.startIndex }
    
    public var endIndex: Backstorage.Index { return _backstorage.endIndex }
    
    private var _backstorage: Backstorage
    
    private var _filter: CollectionFilter<T>

    private var _sort: CollectionSort<T>?
    
    public init(collection: Backstorage,
                filter: CollectionFilter<T>? = nil,
                sort: CollectionSort<T>? = nil) {
        
        self._backstorage = collection
        self._filter = filter != nil ? filter! : { _ in return true }
        self._sort = sort
    }
    
    public func index(after i: Backstorage.Index) -> Backstorage.Index {
        return _backstorage.index(after: i)
    }
    
    public subscript(position: Backstorage.Index) -> T {
        return _backstorage[position]
    }
    
    
    public func updating(_ element: T,
                         whereUnique unique: CollectionFilter<T>,
                         whereCompare compare: CollectionFilter<T>) -> BinUpdateResult<T, CollectionBin> {
        
        let idx = self.index(where: unique)
        
        guard _filter(element) else {
            return idx.map({ removingResult(for: $0, where: unique) })  ?? unchangedBinResult
        }
        
        guard let index = idx, let currentElement = self.element(at: index) else {
            return BinUpdateResult(bin: appendingElement(element), changes: CollectionChanges(addedIndexes: [endIndex]))
        }
        
        return compare(currentElement) ? unchangedBinResult : BinUpdateResult(bin: replacingElement(element, at: index) ,
                                                                            changes: CollectionChanges(updatedIndexes: [index]))
    }
    
    
    public func updating(with elements: Backstorage) -> CollectionBin {
        return CollectionBin(collection: elements, filter: _filter, sort: _sort)
    }
    
    
    private var unchangedBinResult: BinUpdateResult<T, CollectionBin> {
        return BinUpdateResult(bin: self)
    }
    
    private func appendingElement(_ element: T) -> CollectionBin {
        var resp = _backstorage + [element]
        if _sort != nil && _backstorage.count > 0 {
           resp = linearInsert(element)
        }
        return updating(with: resp)
    }
    
    
    private func removingResult(for index: Index, where predicate: CollectionFilter<T>) -> BinUpdateResult<T, CollectionBin>  {
        return BinUpdateResult(bin: updating(with: _backstorage.removing(at: index)),
                               changes: CollectionChanges(removedIndexes: [index]))
    }
    
    private func replacingElement(_ element: T, at index: Index) -> CollectionBin {
        
        return updating(with: _backstorage.replacing(with: element, at: index ))
    }
    
    //Linear insert function assumes that optional _sort is NOT nil
    private func linearInsert(_ element:T) -> Backstorage {
        var inserted = false
        
        var resp = Backstorage()
        //Do a linear search for the proper place for insertation:
        for e in _backstorage {
            if _sort!(e,element) && !inserted {
                resp.append(element)
                inserted = true
                //We don't break from the loop because we continue inserting the rest of the backstorage after element
            }
            resp.append(e)
        }
        
        //If element has not been inserted, insert it at the end:
        if !inserted {
            resp.append(element)
        }
        
        return resp
    }
}


public extension CollectionBin where T: Equatable & Hashable  {
    public func updating(_ element: T) -> BinUpdateResult<T, CollectionBin> {
        return updating(element, whereUnique: { $0.hashValue == element.hashValue }, whereCompare: { $0 == element})
    }
}

extension CollectionBin where Element: CustomStringConvertible {
    public var description: String {
        return _backstorage.map({ "\($0.description)"}).joined(separator: "\n")
    }
}

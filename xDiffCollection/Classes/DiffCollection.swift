//
//  xDiffCollection.swift
//  CollectionTest
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 aldo. All rights reserved.
//

import Foundation
import SwiftyCollection

public typealias DiffCollectionResult = CollectionChanges<IndexPath, [IndexPath]>

public struct DiffCollectionFilter<T: Hashable> {
    public let name : String
    public var filter:(T)->Bool
    
    public init(name: String, filter: @escaping (T)->Bool) {
        self.name = name
        self.filter = filter
    }
}

public typealias DiffCollection<T> = Diff<T, [CollectionBin<T,[T]>]> where T: Hashable & Equatable

public struct Diff<T, C>: Collection where T: Equatable & Hashable, C: RangeReplaceableCollection, C.Element: Collection, C.Element.Element == T, C.Index == Int, C.Element.Index == C.Index {


    public var startIndex: Int { return _backstorage.startIndex }
    
    public var endIndex: Int { return _backstorage.endIndex }
    
  
    public typealias Element = C.Element
    public typealias Index = C.Index
    
    var _backstorage: C
    
    public init(collection: C) {
        _backstorage = collection
    }
    
    public subscript(position: Int) -> C.Element {
        get {
            return _backstorage[position]
        }
        set(newValue) {
            _backstorage = _backstorage.replacing(with: newValue, at: position)
        }
    }
    
    public func index(after i: Int) -> Int {
        return _backstorage.index(after: i)
    }
    
    public subscript(position: IndexPath) -> T? {
        return _backstorage.element(at: position.section)
            .flatMap({ $0.element(at: position.row) })
    }
    
    
    public func numberOfElements(at index: Int) -> Int {
        return element(at: index)?.count ?? 0
    }
    
    //OLD TEST COMPATABILITY
    internal func numberOfElements(inSection: Int) -> Int {
        return numberOfElements(at: inSection)
    }
    
    //OLD TEST COMPATABILITY
    internal func numberOfSections() -> Int {
        return count
    }
    
    //OLD TEST COMPATABILITY
    internal func element(atIndexPath index: IndexPath) -> T? {
        return self[index]
    }
}


public extension DiffCollection where C == [CollectionBin<T,[T]>] {
    init(filters: [DiffCollectionFilter<T>]) {
        
        let collection: [CollectionBin<T,[T]>] = filters.map({ CollectionBin(collection: [], filter: $0.filter) })
    
        _backstorage = collection
    }
    
    func updating(with element: T) -> (collection: Diff, changes: DiffCollectionResult) {

        let result = self.map({ $0.updating(element) })
        
       let changes =  result.map({ $0.changes })
                            .enumerated()
                            .map({ convertChanges($0.element, for: $0.offset) })
                            .reduce(DiffCollectionResult()) { (partial, result) -> DiffCollectionResult in
                
                    let new = DiffCollectionResult(updatedIndexes: join(partial.updatedIndexes, result.updatedIndexes),
                                                   removedIndexes: join(partial.removedIndexes, result.removedIndexes),
                                                   addedIndexes: join(partial.addedIndexes, result.addedIndexes))
                    return new
        }
        return (collection: Diff(collection: result.map({ $0.bin })), changes)
    }
    
    
    
    private func convertChanges(_ changes: CollectionChanges<Index, [Index]>, for section: Int) -> DiffCollectionResult {
        return DiffCollectionResult(updatedIndexes: tranformIndexes(changes.updatedIndexes, forSection: section),
                                    removedIndexes: tranformIndexes(changes.removedIndexes, forSection: section),
                                    addedIndexes: tranformIndexes(changes.addedIndexes, forSection: section))
    }
    
    private func tranformIndexes(_ indexes: [Index], forSection section: Int) -> [IndexPath] {
        return indexes.map({ transformIntoIndexPath(index: $0, forSection: section) } )
    }
    
    private func transformIntoIndexPath(index: Index, forSection section: Int) -> IndexPath {
        return IndexPath(row: index, section: section)
    }
    
 
    private func join(_ left:[IndexPath], _ right: [IndexPath]) -> [IndexPath] {
        return [left, right].joined().compactMap({$0})
    }
    
}

extension Diff: MutableCollection {}

extension Diff where C == [CollectionBin<T,[T]>] {

    @discardableResult
    public mutating func update(with element: T) -> DiffCollectionResult {
        let updateResult =  self.updating(with: element)
        self = updateResult.collection
        return updateResult.changes
    }
    
}

//
//  xDiffCollection.swift
//  CollectionTest
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 aldo. All rights reserved.
//

import Foundation

public struct DiffCollectionResult {
    public var deleted : [IndexPath]
    public var added   : [IndexPath]
    public var updated : [IndexPath]
}

public struct DiffCollectionFilter<T:Hashable> {
    public let name : String
    public var filter:(T)->Bool
    
    public init(name: String, filter: @escaping (T)->Bool) {
        self.name = name
        self.filter = filter
    }
}

public struct DiffCollection<T:Hashable> : CustomStringConvertible {
    private var bins:[CollectionBin<T>] = []
    private init(bins:[CollectionBin<T>]) {
        self.bins = bins
    }
    
    public var description: String {
        var resp = ""
        for bin in bins {
            resp += "Bin\n"
            resp += "\(bin)"
        }
        return resp
    }
    
    public init(filters:[DiffCollectionFilter<T>]) {
        for (idx, binFilter) in filters.enumerated() {
            bins.append(CollectionBin(index: idx, elements: [], filter: binFilter.filter))
        }
    }
    
    public mutating func update(element:T) -> DiffCollectionResult {
        var deletedItems : [IndexPath] = []
        var addedItems : [IndexPath] = []
        var updatedItems : [IndexPath] = []
                
        var resp : [CollectionBin<T>] = []
        for (binIndex, bin) in bins.enumerated() {
            if bin.filter(element) {
                let (newBin,result) =  bin.updated(element)
                switch result.type {
                    case .added:
                        addedItems.append(IndexPath(row: result.idx, section: binIndex))
                    case .updated:
                        updatedItems.append(IndexPath(row: result.idx, section: binIndex))
                    default:
                        fatalError("bin.updated action should return either added or updated statuses")
                }
                resp.append(newBin)
            } else {
                //Element doesn't belong to this bin. Delete it if found in the bin.
                let (newBin,result) = bin.removed(element)
                if result.idx > -1 {
                    deletedItems.append(IndexPath(row: result.idx, section: binIndex))
                }
                resp.append(newBin)
            }
        }
        
        bins = resp
        return DiffCollectionResult(deleted: deletedItems,
                                      added:   addedItems,
                                      updated: updatedItems)
    }
    
    public mutating func delete(element:T) -> DiffCollectionResult {
        var deletedItems : [IndexPath] = []
        var resp : [CollectionBin<T>] = []
        for (binIndex, bin) in bins.enumerated() {
            let (newBin,result) = bin.removed(element)
            if result.idx > -1 {
                deletedItems.append(IndexPath(row: result.idx, section: binIndex))
            }
            resp.append(newBin)
        }
        bins = resp
        return DiffCollectionResult(deleted: deletedItems,
                                      added:   [],
                                      updated: [])
    }
    
    public func element(atIndexPath path:IndexPath) -> T? {
        if path.section < bins.count {
            return bins[path.section].element(at: path.row)
        }
        return nil
    }
    
    public func numberOfElements(inSection binIndex:Int) -> Int {
        if binIndex < bins.count {
            return bins[binIndex].count
        }
        return 0
    }
    
    public func numberOfSections() -> Int {
        return bins.count
    }
}

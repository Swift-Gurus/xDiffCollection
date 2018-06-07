//
//  CollectionBin.swift
//  CollectionTest
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 aldo. All rights reserved.
//

import Foundation

internal enum BinOperationType {
    case updated
    case added
    case deleted
    case none
}

internal struct BinResult {
    var type: BinOperationType
    var idx : Int
}

internal protocol CollectionFiltering {
    func filter<T:Hashable>(_ element:T) -> Bool
}

internal struct CollectionBin<T:Hashable> : CollectionFiltering, CustomStringConvertible {
    var index : Int
    var elements:Array<T> = []
    var filter:(T)->Bool
    var description: String {
        var resp = ""
        for (idx, element) in self.elements.enumerated() {
            resp += "\(idx))\t\(element.hashValue)\n"
        }
        return resp
    }
    var count : Int {
        return elements.count
    }
    
    init(index: Int, filter: @escaping (T)->Bool, elements: Array<T>) {
        self.index = index
        self.filter = filter
        self.elements = elements
    }
    
    func filter<T>(_ element:T) -> Bool {
        return self.filter(element)
    }
    
    func updated(_ element:T) -> (CollectionBin<T>, BinResult) {
        var copy = elements
        if let idx = self.contains(element) {
            copy[idx] = element
            return (CollectionBin(index: self.index, filter: self.filter, elements: copy),BinResult(type: .updated, idx: idx))
        } else {
            copy.append(element)
            return (CollectionBin(index: self.index, filter: self.filter, elements: copy),BinResult(type: .added, idx: copy.count-1))
        }
    }
    
    func removed(_ element:T) -> (CollectionBin<T>, BinResult) {
        var copy = elements
        if let idx = self.contains(element) {
            copy.remove(at: idx)
            return (CollectionBin(index: self.index, filter: self.filter, elements: copy),BinResult(type: .deleted, idx: idx))
        }
        return (CollectionBin(index: self.index, filter: self.filter, elements: copy),BinResult(type: .none, idx: -1))
    }
    
    func contains(_ element:T) -> Int? {
        if let idx = elements.index(where: { $0.hashValue == element.hashValue }) {
            return idx
        }
        return nil
    }
    
    func element(at index:Int) -> T? {
        if index < elements.count {
            return elements[index]
        }
        
        return nil
    }
}

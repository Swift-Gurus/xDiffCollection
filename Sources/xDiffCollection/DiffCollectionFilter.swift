//
//  File.swift
//  
//
//  Created by Alex Hmelevski on 2020-05-10.
//

import Foundation

public typealias DiffCollectionSort<T> = (T, T) -> Bool

public struct DiffCollectionFilter<T: Hashable> {
    public let name: String
    public var filter: (T) -> Bool
    public var sort: ((T, T) -> Bool)?

    public init(name: String,
                filter: @escaping (T) -> Bool,
                sort: DiffCollectionSort<T>? = nil ) {
        self.name = name
        self.filter = filter
        self.sort = sort
    }

    func replacedSort(_ sort: @escaping DiffCollectionSort<T>) -> Self {
        .init(name: name, filter: filter, sort: sort)
    }
}

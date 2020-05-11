//
//  File.swift
//  
//
//  Created by Alex Hmelevski on 2020-05-10.
//

import Foundation

/// Generic struct that contains configuration for a one Bin/Section
/// - Note:
///   Elements of the collection should conform to `Hashable`
///   It is very important to chose hash fucntion or value correctly since
///  `CollectionBin<Backstorage>` will use it to identify the elements
public struct DiffCollectionFilter<T: Hashable> {
    
    /// Name or unique id of the sections
    public let name: String
    
    /// Rules for elements that should be in the section
    public var filter: CollectionFilter<T>
    
    /// Sorting rules for the section
    public var sort: CollectionSort<T>?

    /// Main constructor
    /// - Parameters:
    ///   - name: Unique ID of the section
    ///   - filter: Rules for elements that should be in the section
    ///   - sort: Sorting rules for the section
    ///
    /// - Note:
    ///     If sorting is nil, then a new element is added to the end of the `CollectionBin<Backstorage>`
    public init(name: String,
                filter: @escaping CollectionFilter<T>,
                sort: CollectionSort<T>? = nil ) {
        self.name = name
        self.filter = filter
        self.sort = sort
    }

    func replacedSort(_ sort: @escaping CollectionSort<T>) -> Self {
        .init(name: name, filter: filter, sort: sort)
    }
}

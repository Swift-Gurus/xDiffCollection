//
//  CollectionChanges.swift
//  xDiffCollection
//
//  Created by Alex Hmelevski on 2018-06-18.
//

import Foundation

/**
    Struct that contains information about added/removed/updated indexes
    Indexes are represented by any colection:
 
    ### Usage example: ###
    ````
     let changes = CollectionChanges<[Int]>(updatedIndexes: [0,2,3],
                                            emovedIndexes: [1],
                                            addedIndexes: [4])
 
    ````    
*/
public struct CollectionChanges<C: Collection> {
    
    /// Contains updated indexes
    public  let updatedIndexes: C
    
    /// Contains removed  indexes
    public let removedIndexes: C
    
    /// Contains added indexes
    public let addedIndexes: C

    /// initialize changes
    /// - Parameters:
    ///   - updatedIndexes: Collection of Updated Indexes
    ///   - removedIndexes: Collection of Removed Indexes
    ///   - addedIndexes: Collection of Added Indexes
    public init(updatedIndexes: C,
                removedIndexes: C,
                addedIndexes: C) {
        self.updatedIndexes = updatedIndexes
        self.addedIndexes = addedIndexes
        self.removedIndexes = removedIndexes
    }
}

extension CollectionChanges where C: RangeReplaceableCollection {

     init(updatedIndexes: C = C(),
          removedIndexes: C = C(),
          addedIndexes: C = C()) {
        self.updatedIndexes = updatedIndexes
        self.addedIndexes = addedIndexes
        self.removedIndexes = removedIndexes
    }
}

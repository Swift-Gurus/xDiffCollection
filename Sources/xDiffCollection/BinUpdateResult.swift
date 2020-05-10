//
//  BinUpdateResult.swift
//  xDiffCollection
//
//  Created by Alex Hmelevski on 2018-06-18.
//

import Foundation

/**
    Struct that contains updated storage and changes applied to it
 
    ### Example: ###
    ````swift
    struct AnyModel {
        // any implementation
    }
 
    let result: BinUpdateResult<[AnyModel]> = // returned by a function
    // result.bin is a type of [AnyModel]
    // result.changes is a type of CollectionChanges<[Int]>
 
    ````
 */
public struct BinUpdateResult<Backstorage: Collection> {

    /// Any type that conforms to Collection
    public let bin: Backstorage

    /**
        CollectionChanges where element is an array of Index type that  used by the Backstorage
     
        Let's say we have a model `AnyModel`  and the storage is `Array<AnyModel>` then
        changes will be a type of `CollectionChanges<[Int]>` since `Int` is an index of
         `Array<AnyModel>`
     */
    public let changes: CollectionChanges<[Backstorage.Index]>

    init(bin: Backstorage,
         changes: CollectionChanges<[Backstorage.Index]> = CollectionChanges()) {
        self.bin = bin
        self.changes = changes
    }
}

//
//  DiffCollectionSnapshot.swift
//  xDiffCollection
//
//  Created by Alex Hmelevski on 2020-04-23.
//

import Foundation

/// Respresents a snapshot of a collection after updating with an element
/// Contains info about the element, new collection and changes
public struct DiffCollectionSnapshot<E: Hashable> {

    /// Element that was used for updates
    public let element: E

    /// New collection with updated element
    public let collection: DiffCollection<E>

    /// Changes about updated indexes
    public let changes: DiffCollectionResult
}

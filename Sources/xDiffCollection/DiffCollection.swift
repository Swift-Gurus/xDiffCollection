//
//  xDiffCollection.swift
//  CollectionTest
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 aldo. All rights reserved.
//

import Foundation
import SwiftyCollection

// Convenience typealias that represents collection changes
public typealias DiffCollectionResult = CollectionChanges<[IndexPath]>

// Convenience typealias that represents Diff
public typealias DiffCollection<T> = Diff<T, [CollectionBin<[T]>]> where T: Hashable & Equatable


/**
 `Diff` is a concept of a container for multiple collections and provides methods to access elements of those collections
   *Example*:
    ````
        let names = ["Adams", "Bryant", "Channing"]
        let cars = ["Ford", "Dodge"]
        let collection = Diff([names,cars])
        let subSequence = collection[1]
        print(subSequence)
        // ["Ford", "Dodge"]
    
        let element = collection[IndexPath(row: 0,section: 1)]
        print(element)
        // "Ford"
    ````
 
 
  Contains a very powerful **extension** for `Diff`where  `C` == [`CollectionBin<[T]>`] that
  provides logic for updating element and putting it in propper subcollections of type `CollectionBin<[T]>`

  An update operation returns `DiffCollectionSnapshot<T>` containing modifications made to the collection and
  its subcollections.
 
    **Usage Example**
    - Define a model
    ````
       //let's have a model like
       struct TestObject: Hashable, Equatable {
            var value: String
            var status: ObjectStatus
            var rank: Int

            
            func hash(into hasher: inout Hasher) {
                hasher.combine(value)
                hasher.combine(rank)
            }

           // -Note: since value and rank are a part of unique value of the object the only part that
           // cab be changed is the status
            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.status  == rhs.status
            }
       }
    ````
    - Define filters for sections:

    ````
        let startsARankSorted = DiffCollectionFilter<TestObject>(name: "Starts with a",
                                                                 filter: { $0.value.starts(with: "a") },
                                                                 sort: { $0.rank > $1.rank })

        let startedBValueSorted = DiffCollectionFilter<TestObject>(name: "Starts with b",
                                                                   filter: { $0.value.starts(with: "b") },
                                                                   sort: { $0.value > $1.value })
    ````
        
    - initialize `Diff`

    ````
        var diffCollection = [startsARankSorted, startedBValueSorted]
    ````

    - Start using by calling upade function

    ````
        let elementA = TestObject(value: "Arm",
                                  status: .new,
                                  rank: 100)
        let snapshot = diffCollection.update(with: elementA)
        debugPrint(snapshot.changes)
        // updatedIndexes = [], removedIndexes = [], addedIndexes = [IndexPath(row: 0, section: 0)]
    ````
 */
public struct Diff<T, C>: Collection where
T: Equatable & Hashable,
C: RangeReplaceableCollection,
C.Element: Collection,
C.Element.Element == T,
C.Index == Int,
C.Element.Index == C.Index {

    /// Start index of the `C`
    public var startIndex: C.Index { return _backstorage.startIndex }

    /// End  index of the `C`
    public var endIndex: C.Index { return _backstorage.endIndex }

    // Convenience typealias for `C.Index`
    public typealias Element = C.Element
    
    // Convenience typealias for `C.Element`
    public typealias IndexType = C.Index

    var _backstorage: C

    public init(collection: C) {
        _backstorage = collection
    }
    
    /// Geter and setter of  the element specified
    /// by an `IndexType`.
    ///
    ///     let names = ["Adams", "Bryant", "Channing"]
    ///     let cars = ["Ford", "Dodge"]
    ///     let collection = Diff([names,cars])
    ///     let element = collection[1]
    ///     print(element)
    ///     // ["Ford", "Dodge"]
    ///
    /// - Parameter Index: A index of the element(`C`). The index
    ///   must be valid.
    ///
    /// - Complexity: O(n)
    public subscript(position: IndexType) -> C.Element {
        get {
            return _backstorage[position]
        }
        set(newValue) {
            _backstorage = _backstorage.replacing(with: newValue, at: position)
        }
    }

    /// Returns the position immediately after the given index.
    ///
    /// The successor of an index must be well defined. For an index `i` into a
    /// collection `c`, calling `c.index(after: i)` returns the same index every
    /// time.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: IndexType) -> IndexType {
        return _backstorage.index(after: i)
    }

    /// Accesses  the element specified
    /// by an `IndexPath`.
    ///
    ///     let names = ["Adams", "Bryant", "Channing"]
    ///     let cars = ["Ford", "Dodge"]
    ///     let collection = Diff([names,cars])
    ///     let element = collection[IndexPath(row: 0,section: 1)]
    ///     print(element)
    ///     // "Ford"
    ///
    /// - Parameter Index: A index of the element(`C`). The index
    ///   must be valid.
    ///
    /// - Complexity: O(n)
    public subscript(position: IndexPath) -> T? {
        return _backstorage.element(at: position[0])
                           .flatMap({ $0.element(at: position[1]) })
    }

    /// Retuns number of elements in collection at `IndexType`
    /// - Parameter index: IndexType
    /// - Returns: Int
    public func numberOfElements(at index: IndexType) -> Int {
        return element(at: index)?.count ?? 0
    }

    //OLD TEST COMPATABILITY
    internal func numberOfElements(inSection: IndexType) -> Int {
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



public extension Diff where C == [CollectionBin<[T]>] {
    
    /// Constructor that uses a collection of `DiffCollectionFilter<T>`
    /// to specify rules per every section
    /// - Parameter filters: [`DiffCollectionFilter<T>`]
    init(filters: [DiffCollectionFilter<T>]) {
        _backstorage = filters.map({ CollectionBin(collection: [], filter: $0.filter, sort: $0.sort) })
    }

    @available(*, deprecated)
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

    private func convertChanges(_ changes: CollectionChanges<[C.Index]>, for section: Int) -> DiffCollectionResult {
        return DiffCollectionResult(updatedIndexes: tranformIndexes(changes.updatedIndexes, forSection: section),
                                    removedIndexes: tranformIndexes(changes.removedIndexes, forSection: section),
                                    addedIndexes: tranformIndexes(changes.addedIndexes, forSection: section))
    }

    private func tranformIndexes(_ indexes: [C.Index], forSection section: Int) -> [IndexPath] {
        return indexes.map({ transformIntoIndexPath(index: $0, forSection: section) })
    }

    private func transformIntoIndexPath(index: C.Index, forSection section: C.Index) -> IndexPath {
        return IndexPath(indexes: [section, index])
    }

    private func join(_ left: [IndexPath], _ right: [IndexPath]) -> [IndexPath] {
        return [left, right].joined().compactMap({ $0 })
    }
    
    
    /**

        The main core function of the `Diff`.
        Based on the settings `DiffCollectionFilter<T>` for subcollections `CollectionBin<[T]>`
        will add, remove or update element in those subcollections
     
    - Parameter element: Element of Type `T`
    - Returns: DiffCollectionSnapshot<T>
    */
    @discardableResult
    
     mutating func update(with element: T) -> DiffCollectionSnapshot<T> {
         let result: DiffCollectionSnapshot<T> = updating(using: element)
         self = result.collection
         return result
     }

     /**

        The main core function of the `Diff`.
        Based on the settings `DiffCollectionFilter<T>` for subcollections `CollectionBin<[T]>`
        will add, remove or update element in those subcollections
         
        - Parameter element: Element of Type `T`
        - Returns: DiffCollectionSnapshot<T>
      */
     func updating(using element: T) -> DiffCollectionSnapshot<T> {
         let result = updating(with: element)
         return DiffCollectionSnapshot(element: element,
                                       collection: result.collection,
                                       changes: result.changes)
     }

}

extension Diff: MutableCollection {}

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
public typealias CollectionSort<T> = (T, T) -> Bool

/**
    Represents a Facade for `RangeReplaceableCollection` that is a `Collection` itself

    Provides `updating` method to `find` the element  if it exists and `update` or `remove` it
    based on the rules provided by `CollectionFilter<Element>`

    If `Backstorage` doesn't contain the element and the element complies to the rules, `updating` method
    will append the element
 
    Every call of `updating` method returns `BinUpdateResult<CollectionBin>` that contains info about
    the update operation
 
   `CollectionBin` can be initialized with filter and sorting closures specifying the rules how to treat the elements.
    
    **Example**
    ````
    //let's have a model  like
    struct CollectionTestObjectMock: Hashable, Equatable {
         var value: String
         var status: ObjectStatus
         var rank: Int

         
         func hash(into hasher: inout Hasher) {
             hasher.combine(value)
             hasher.combine(rank)
         }

        // -Note: since value and rank are a part of unique value of the object the only part that
        // cab be changed is the status
         static func == (lhs: CollectionTestObjectMock, rhs: CollectionTestObjectMock) -> Bool {
             lhs.status  == rhs.status
         }
    }
 
    ````
 
    Then a basic initizlization will be:
    ````
        //Will contain object with status == .cold and sorted by rank descending
        DiffCollectionFilter<CollectionTestObjectMock>(name: "Status is new or old",
                                                       filter: { $0.status == .cold},
                                                       sort: { $0.rank > $1.rank })
    ````
    
 */
public struct CollectionBin<Backstorage: RangeReplaceableCollection>: Collection {

    // Convenience typealias for `Backstorage.Index`
    public typealias Index = Backstorage.Index
    
    // Convenience typealias for `Backstorage.Element`
    public typealias Element = Backstorage.Element

    
    /// Start index of the `Backstorage`
    public var startIndex: Backstorage.Index { return _backstorage.startIndex }

    /// End  index of the `Backstorage`
    public var endIndex: Backstorage.Index { return _backstorage.endIndex }

    private var _backstorage: Backstorage

    private var _filter: CollectionFilter<Element>

    private var _sort: CollectionSort<Element>?

    /// Main constructor for the struct
    /// - Parameters:
    ///   - collection: Any `RangeReplaceableCollection`
    ///   - filter: Provides rules to insert/delete/update elements
    ///   - sort: Provides sorting rules for injecting elements.
    public init(collection: Backstorage,
                filter: CollectionFilter<Element>? = nil,
                sort: CollectionSort<Element>? = nil) {

        self._backstorage = collection
        self._filter = filter ?? { _ in return true }
        self._sort = sort
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
    public func index(after i: Index) -> Backstorage.Index {
        return _backstorage.index(after: i)
    }

    /// Accesses the element specified
    /// by an Index.
    ///
    ///     let names = CollectionBin(["Adams", "Bryant", "Channing", "Douglas", "Evarts"])
    ///     let name = streets[2]
    ///     print(streetsSlice)
    ///     // "Channing"
    ///
    /// - Parameter Index: A index of the element. The index
    ///   must be valid.
    ///
    /// - Complexity: O(1)
    public subscript(position: Index) -> Element {
        return _backstorage[position]
    }

    /**
       The core function of this struct.
        - Parameters:
          - element: Element
          - unique: CollectionFilter<Element>  closure that  defines the uniqueness of the element
          - compare: CollectionFilter<Element> closure that  defines the changes of the element
        - Returns: `BinUpdateResult<CollectionBin>`
     
     
        
        **Usage Example:**
        ````
        //let's have a model  like
        struct CollectionTestObjectMock: Hashable, Equatable {
             let value: String
             let status: ObjectStatus
             let rank: Int
        }
     
        ````
        Then the call of the function might look like:
        ````
        let newElement = CollectionTestObjectMock(value: "TEST",
                                                  status: .new,
                                                  rank: 150)
        let result = source.updating(newElement,
                                     whereUnique: { $0.value == "TEST" },
                                     whereCompare: { $0.status == .new })
        ````
        NOTE:  The method will try to look for an element with "TEST" value.
        - if the element exist then based on compare closure it will update an element or will do noting
        - if the element exist but doest pass filter function of the Bin, the element will be removed
     
     */
    public func updating(_ element: Element,
                         whereUnique unique: CollectionFilter<Element>,
                         whereCompare compare: CollectionFilter<Element>) -> BinUpdateResult<CollectionBin> {

        let idx = self.firstIndex(where: unique)

        guard _filter(element) else {
            return idx.map({ removingResult(for: $0, where: unique) })  ?? unchangedBinResult
        }

        guard let index = idx, let currentElement = self.element(at: index) else {
            let (collection, insertionIndex) = appendingElement(element)
            return BinUpdateResult(bin: collection,
                                   changes: CollectionChanges(addedIndexes: [_backstorage.index(startIndex, offsetBy: insertionIndex)]))
        }

        return compare(currentElement) ? unchangedBinResult : BinUpdateResult(bin: replacingElement(element, at: index) ,
                                                                              changes: CollectionChanges(updatedIndexes: [index]))
    }

    /// Recreates a new `CollectionBin` using the same Filter and Sorting but new collection of elelemts
    /// - Parameter elements: Collection of elements of type `Backstorage`
    /// - Returns: `CollectionBin`
    public func updating(with elements: Backstorage) -> CollectionBin {
        return CollectionBin(collection: elements, filter: _filter, sort: _sort)
    }

    private var unchangedBinResult: BinUpdateResult<CollectionBin> {
        return BinUpdateResult(bin: self)
    }

    private func appendingElement(_ element: Element) -> (CollectionBin, Int) {
        var resp = _backstorage + [element]
        var idx = _backstorage.count
        if let sort = _sort,
            !_backstorage.isEmpty {
            (resp, idx) = linearInsert(element, with: sort)
        }
        return (updating(with: resp), idx)
    }

    private func removingResult(for index: Index, where predicate: CollectionFilter<Element>) -> BinUpdateResult<CollectionBin> {
        return BinUpdateResult(bin: updating(with: _backstorage.removing(at: index)),
                               changes: CollectionChanges(removedIndexes: [index]))
    }

    private func replacingElement(_ element: Element, at index: Index) -> CollectionBin {

        return updating(with: _backstorage.replacing(with: element, at: index ))
    }

    private func linearInsert(_ element: Element,
                              with sort: CollectionSort<Element>) -> (Backstorage, Int) {
        var inserted = false

        var resp = Backstorage()
        var insertionIdx = 0
        //Do a linear search for the proper place for insertation:
        for (idx, e) in _backstorage.enumerated() {
            if sort(element, e) && !inserted {
                resp.append(element)
                inserted = true
                insertionIdx = idx
                //We don't break from the loop because we continue inserting the rest of the backstorage after element
            }
            resp.append(e)
        }

        //If element has not been inserted, insert it at the end:
        if !inserted {
            insertionIdx = resp.count
            resp.append(element)
        }

        return (resp, insertionIdx)
    }
}

public extension CollectionBin where Element: Equatable & Hashable {
    
    /**
      The core function of this struct.
       - Parameters:
         - element: Element as `Hashable` and `Equatable`
       - Returns: `BinUpdateResult<CollectionBin>`
    

       **Note**:
        - Hash value is used to idenfy the unique element
        - Conformance to `Equatable` is used to identify if an element has changed or not
       
       **Usage Example:**
       ````
        //let's have a model  like
         struct CollectionTestObjectMock: Hashable, Equatable {
              var value: String
              var status: ObjectStatus
              var rank: Int

              
              func hash(into hasher: inout Hasher) {
                  hasher.combine(value)
                  hasher.combine(rank)
              }

             // -Note: since value and rank are a part of unique value of the object the only part that
             // cab be changed is the status
              static func == (lhs: CollectionTestObjectMock, rhs: CollectionTestObjectMock) -> Bool {
                  lhs.status  == rhs.status
              }
         }
    
       ````
       Then the call of the function might look like:
       ````
       let newElement = CollectionTestObjectMock(value: "TEST",
                                                 status: .new,
                                                 rank: 150)
       let result = source.updating(newElement)
       ````
       NOTE:  The method will try to look for an element with "TEST" value and rank 150 (since they participate in hash value)
       - if the element exists then based on Hash value  it will update an element or will do noting
       - if the element exists but doest pass filter function of the Bin, the element will be removed
       - if the element exists, passed filter function but not equal to existed one, it will be updated, otherwise no operation is performed
        
    */
    func updating(_ element: Element) -> BinUpdateResult<CollectionBin> {
        return updating(element,
                        whereUnique: { $0.hashValue == element.hashValue },
                        whereCompare: { $0 == element })
    }
}

extension CollectionBin where Element: CustomStringConvertible {
    
    /// Provides convenient description for debug purposes
    public var description: String {
        return _backstorage.map({ "\($0.description)" }).joined(separator: "\n")
    }
}

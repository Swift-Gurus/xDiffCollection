//
//  CollectionTestSortingTests.swift
//  xDiffCollection_Tests
//
//  Created by Esteban Garro on 2018-09-13.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import xDiffCollection

private let object1 = CollectionTestObjectMock(value: "apple", rank: 110)
private let object2 = CollectionTestObjectMock(value: "apple", rank: 210)
private let object3 = CollectionTestObjectMock(value: "apple", rank: 310)
private let object4 = CollectionTestObjectMock(value: "apple", rank: 410)
private let object5 = CollectionTestObjectMock(value: "bacon", rank: 120)
private let object6 = CollectionTestObjectMock(value: "bacon", rank: 220)
private let object7 = CollectionTestObjectMock(value: "bacon", rank: 320)
private let object8 = CollectionTestObjectMock(value: "bacon", rank: 420)
private let object9 = CollectionTestObjectMock(value: "zulu", rank: 130)
private let object10 = CollectionTestObjectMock(value: "zulu", rank: 230)
private let object11 = CollectionTestObjectMock(value: "zulu", rank: 330)
private let object12 = CollectionTestObjectMock(value: "zulu", rank: 430)

extension String {
    func starts<PossiblePrefix>(withPrefixes possiblePrefixes: [PossiblePrefix]) -> Bool where
        PossiblePrefix: Sequence, Self.Element == PossiblePrefix.Element {
        possiblePrefixes.first(where: { self.starts(with: $0) }).flatMap({ $0.underestimatedCount != 0 }) ?? false

    }
}

class CollectionTestSortingTests: XCTestCase {

    var tester: DiffCollectionTester! = nil

    override func setUp() {
        super.setUp()

        //Sort by value first descending and then by rank ascending
        let f1Sort: DiffCollectionSort<CollectionTestObjectMock> = { $0.value > $1.value || ($0.value == $1.value && $0.rank < $1.rank) }
        let f1 = getFilter(with: "Value starts with a or z", canStartWith: ["a", "z"]).replacedSort(f1Sort)
        //Sort by rank descending
        let f2 = getFilter(with: "Value starts with b", canStartWith: ["b"]).replacedSort({ $0.rank > $1.rank })

        tester = DiffCollectionTester(collection: DiffCollection(filters: [f1, f2]))
    }

    private func getFilter(with id: String,
                           canStartWith values: [String]) -> DiffCollectionFilter<CollectionTestObjectMock> {
        return .init(name: id, filter: { $0.value.starts(withPrefixes: values) })
    }

    override func tearDown() {
        super.tearDown()
    }
/*

Desired result after sorting:
Section 0:
     fileprivate let object9 = CollectionTestObjectMock(value:"zulu",rank:130)
     fileprivate let object10 = CollectionTestObjectMock(value:"zulu",rank:230)
     fileprivate let object11 = CollectionTestObjectMock(value:"zulu",rank:330)
     fileprivate let object12 = CollectionTestObjectMock(value:"zulu",rank:430)
     fileprivate let object1 = CollectionTestObjectMock(value:"apple",rank:110)
     fileprivate let object2 = CollectionTestObjectMock(value:"apple",rank:210)
     fileprivate let object3 = CollectionTestObjectMock(value:"apple",rank:310)
     fileprivate let object4 = CollectionTestObjectMock(value:"apple",rank:410)
Section 1:
     fileprivate let object8 = CollectionTestObjectMock(value:"bacon",rank:420)
     fileprivate let object7 = CollectionTestObjectMock(value:"bacon",rank:320)
     fileprivate let object6 = CollectionTestObjectMock(value:"bacon",rank:220)
     fileprivate let object5 = CollectionTestObjectMock(value:"bacon",rank:120)

*/

    //Add all elements in random order:
    func test_Fillup_Collection() {
        tester.testAdd(element: object4)
        tester.testAdd(element: object7)
        tester.testAdd(element: object9)
        tester.testAdd(element: object1)
        tester.testAdd(element: object12)
        tester.testAdd(element: object6)
        tester.testAdd(element: object2)
        tester.testAdd(element: object8)
        tester.testAdd(element: object3)
        tester.testAdd(element: object10)
        tester.testAdd(element: object11)
        tester.testAdd(element: object5)
    }

    func test_Filters_Providing_Sorting_Function_Must_Always_Remain_Sorted() {
        test_Fillup_Collection()

        //After filling up collection, elements must be in sorted order, not in insertion order:
        let sortedOrder = [ [object9, object10, object11, object12, object1, object2, object3, object4],
                            [object8, object7, object6, object5]
                          ]
        XCTAssertEqual(sortedOrder, tester.myCollection.compactMap({ $0.map({ $0 }) }))
    }

    func test_Adding_a_New_Object_Must_Inserted_at_Proper_Index() {
        test_Fillup_Collection()

        let objectA = CollectionTestObjectMock(value: "zapato", status: .new, rank: 150)
        //Must insert after element (zulu,430) at (4,0):
        var sortedOrder = [ [object9, object10, object11, object12, objectA, object1, object2, object3, object4],
                            [object8, object7, object6, object5]
        ]

        var resp = tester.testAdd(element: objectA)
        XCTAssertEqual(sortedOrder, tester.myCollection.compactMap({ $0.map({ $0 }) }))

        XCTAssertEqual(resp.addedIndexes, [IndexPath(row: 4, section: 0)])
        XCTAssert(resp.updatedIndexes.isEmpty)
        XCTAssert(resp.removedIndexes.isEmpty)

        //Must insert at the very begining of section 0 at (0,0)
        let objectB = CollectionTestObjectMock(value: "zynching", status: .new, rank: 150)
        sortedOrder = [[objectB, object9, object10, object11, object12, objectA, object1, object2, object3, object4],
                       [object8, object7, object6, object5]
        ]

        resp = tester.testAdd(element: objectB)
        XCTAssertEqual(sortedOrder, tester.myCollection.compactMap({ $0.map({ $0 }) }))

        XCTAssertEqual(resp.addedIndexes, [IndexPath(row: 0, section: 0)])
        XCTAssert(resp.updatedIndexes.isEmpty)
        XCTAssert(resp.removedIndexes.isEmpty)

        //Must insert at the second section after (bacon,420) (1,1)
        let objectC = CollectionTestObjectMock(value: "bacon", status: .new, rank: 370)
        sortedOrder = [[objectB, object9, object10, object11, object12, objectA, object1, object2, object3, object4],
                       [object8, objectC, object7, object6, object5]
        ]

        resp = tester.testAdd(element: objectC)
        XCTAssertEqual(sortedOrder, tester.myCollection.compactMap({ $0.map({ $0 }) }))

        XCTAssertEqual(resp.addedIndexes, [IndexPath(row: 1, section: 1)])
        XCTAssert(resp.updatedIndexes.isEmpty)
        XCTAssert(resp.removedIndexes.isEmpty)
    }
}

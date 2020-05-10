//
//  CollectionTestTests.swift
//  CollectionTestTests
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 aldo. All rights reserved.
//

import XCTest
@testable import xDiffCollection

#if os(macOS)
extension IndexPath {
    var section: IndexPath.Element {
        self[0]
    }
    var row: IndexPath.Element {
        self[1]
    }

    init(row: Int, section: Int) {
        self.init(indexes: [section, row])
    }
}
#endif

private let object1 = CollectionTestObjectMock(value: "apple")
private let object2 = CollectionTestObjectMock(value: "ansi")
private let object3 = CollectionTestObjectMock(value: "bacon")
private let object4 = CollectionTestObjectMock(value: "cocoon")

class CollectionTestTests: XCTestCase {
    var tester: DiffCollectionTester! = nil

    override func setUp() {
        super.setUp()
        let f1 = getFilter(with: "Starts with a", canStartWith: ["a"])
        let f2 = getFilter(with: "Starts with b", canStartWith: ["b"])
        let f3 = getFilter(with: "Starts with c", canStartWith: ["c"])

        tester = DiffCollectionTester(collection: DiffCollection(filters: [f1, f2, f3]))
    }

    private func getFilter(with id: String,
                           canStartWith values: [String]) -> DiffCollectionFilter<CollectionTestObjectMock> {
           return .init(name: id, filter: { $0.value.starts(withPrefixes: values) })
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_Fillup_Collection() {

        tester.testElementIsAddedAt(indexPath: IndexPath(row: 0, section: 0),
                                             element: object1)
        tester.testElementIsAddedAt(indexPath: IndexPath(row: 1, section: 0),
                                             element: object2)
        tester.testElementIsAddedAt(indexPath: IndexPath(row: 0, section: 1),
                                             element: object3)
        tester.testElementIsAddedAt(indexPath: IndexPath(row: 0, section: 2),
                                             element: object4)
    }

    func test_Update_Collection() {
        test_Fillup_Collection()

        var objectClone = object2
        objectClone.status = .cold

        tester.testElementIsUpdatedAt(indexPath: IndexPath(row: 1, section: 0),
                                      element: objectClone)
    }
}

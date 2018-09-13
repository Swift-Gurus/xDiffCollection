//
//  CollectionTestSortingTests.swift
//  xDiffCollection_Tests
//
//  Created by Esteban Garro on 2018-09-13.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import xDiffCollection

fileprivate let object1 = CollectionTestObjectMock(value:"apple",rank:110)
fileprivate let object2 = CollectionTestObjectMock(value:"apple",rank:210)
fileprivate let object3 = CollectionTestObjectMock(value:"apple",rank:310)
fileprivate let object4 = CollectionTestObjectMock(value:"apple",rank:410)
fileprivate let object5 = CollectionTestObjectMock(value:"bacon",rank:120)
fileprivate let object6 = CollectionTestObjectMock(value:"bacon",rank:220)
fileprivate let object7 = CollectionTestObjectMock(value:"bacon",rank:320)
fileprivate let object8 = CollectionTestObjectMock(value:"bacon",rank:420)
fileprivate let object9 = CollectionTestObjectMock(value:"zulu",rank:130)
fileprivate let object10 = CollectionTestObjectMock(value:"zulu",rank:230)
fileprivate let object11 = CollectionTestObjectMock(value:"zulu",rank:330)
fileprivate let object12 = CollectionTestObjectMock(value:"zulu",rank:430)

class CollectionTestSortingTests: XCTestCase {
    
    var tester : DiffCollectionTester! = nil
    
    override func setUp() {
        super.setUp()

        //Sort by value first descending and then by rank ascending
        let f1 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Value starts with a or z", filter:{ s in
            if(s.value.starts(with: "a") || s.value.starts(with: "z")) {
                return true
            }
            return false
        }) { return $0.value < $1.value || ($0.value == $1.value && $0.rank > $1.rank) }
        
        //Sort by rank descending
        let f2 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Value starts with b", filter:{ s in
            if(s.value.starts(with: "b")) {
                return true
            }
            return false
        }) { return $0.rank < $1.rank }
        
        tester = DiffCollectionTester(collection:DiffCollection(filters: [f1,f2]))
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //Add elements in random orders:
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

        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 0, section: 0), element: object9)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 1, section: 0), element: object10)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 2, section: 0), element: object11)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 3, section: 0), element: object12)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 4, section: 0), element: object1)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 5, section: 0), element: object2)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 6, section: 0), element: object3)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 7, section: 0), element: object4)
        
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 0, section: 1), element: object8)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 1, section: 1), element: object7)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 2, section: 1), element: object6)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 3, section: 1), element: object5)
    }
    
    func test_Adding_a_New_Object_Must_Inserted_at_Proper_Index() {
        test_Fillup_Collection()
        
        var object = CollectionTestObjectMock(value: "zapato", status: .new, rank: 150)
        tester.testAdd(element: object)
        
        //Must insert after element (zulu,430) at (4,0)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 4, section: 0), element: object)
        
        
        object = CollectionTestObjectMock(value: "zynching", status: .new, rank: 150)
        tester.testAdd(element: object)
        
        //Must insert at the very begining at (0,0)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 0, section: 0), element: object)
        
        
        object = CollectionTestObjectMock(value: "bacon", status: .new, rank: 370)
        tester.testAdd(element: object)
        
        //Must insert at the very begining at the second section after (bacon,420) (1,1)
        tester.testElementAtIndexPathIsEqualTo(indexPath: IndexPath(row: 1, section: 1), element: object)
    }
    
}

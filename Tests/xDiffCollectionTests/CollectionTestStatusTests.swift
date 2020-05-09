//
//  CollectionTestStatusTests.swift
//  CollectionTestTests
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 aldo. All rights reserved.
//

import XCTest
@testable import xDiffCollection

fileprivate let object1 = CollectionTestObjectMock(value:"apple")
fileprivate let object2 = CollectionTestObjectMock(value:"ansi")
fileprivate let object3 = CollectionTestObjectMock(value:"bacon")
fileprivate let object4 = CollectionTestObjectMock(value:"cocoon")

class CollectionTestStatusTests: XCTestCase {
    
    var tester : DiffCollectionTester! = nil
    
    override func setUp() {
        super.setUp()
        
        let f1 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Status is new", filter:{ s in
            if(s.status == .new) {
                return true
            }
            return false
        })
        
        let f2 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Status is old", filter:{ s in
            if(s.status == .old) {
                return true
            }
            return false
        })
        
        let f3 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Starts is hot", filter:{ s in
           if(s.status == .hot) {
                return true
            }
            return false
        })
        
        let f4 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Starts is cold", filter:{ s in
            if(s.status == .cold) {
                return true
            }
            return false
        })
        
        tester = DiffCollectionTester(collection:DiffCollection(filters: [f1,f2,f3,f4]))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Fillup_Collection() {
        tester.testElementIsAddedAt(indexPath:IndexPath(row:0, section:0),
                                    element:object1)
        tester.testElementIsAddedAt(indexPath:IndexPath(row:1, section:0),
                                    element:object2)
        tester.testElementIsAddedAt(indexPath:IndexPath(row:2, section:0),
                                    element:object3)
        tester.testElementIsAddedAt(indexPath:IndexPath(row:3, section:0),
                                    element:object4)
    }

    func test_Update_Element_That_Matches_No_Filter_Should_Return_Three_Empty_Arrays() {
        test_Fillup_Collection()
        
        var object = CollectionTestObjectMock(value: "NewObject")
        object.status = .other
        
        tester.testElementOperationMatchingNoFilterLeavesCollectionUnchanged(element: object)
    }
    
    func test_Update_Status_Should_Delete_From_And_Add_To_Bin() {
        test_Fillup_Collection()
        
        var objectClone = object3
        objectClone.status = .old
        
        tester.testElementIsAddedAtAndDeletedFrom(element: objectClone,
                                                  at: IndexPath(row: 0, section: 1),
                                                  from: IndexPath(row: 2, section: 0))
        objectClone.status = .hot
        
        
        tester.testElementIsAddedAtAndDeletedFrom(element: objectClone,
                                                  at: IndexPath(row: 0, section: 2),
                                                  from: IndexPath(row: 0, section: 1))
    }
    
}

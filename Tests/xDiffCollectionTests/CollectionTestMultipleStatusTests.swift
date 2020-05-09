//
//  CollectionTestMultipleStatusTests.swift
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

class CollectionTestMultipleStatusTests: XCTestCase {
    var tester : DiffCollectionTester! = nil
    
    override func setUp() {
        super.setUp()
        
        let f1 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Status is new or old", filter:{ s in
            if(s.status == .new || s.status == .old) {
                return true
            }
            return false
        })
        
        let f2 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Status is hot or cold", filter:{ s in
            if(s.status == .hot || s.status == .cold) {
                return true
            }
            return false
        })
        
        tester = DiffCollectionTester(collection:DiffCollection(filters: [f1,f2]))
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
    
    func test_Changing_Status_Within_Same_Bucket_Should_Update_Element() {
        test_Fillup_Collection()
        
        var objectClone = object3
        objectClone.status = .old
        
       tester.testElementIsUpdatedAt(indexPath:IndexPath(row: 2, section: 0),
                                     element: objectClone)
    }
    
    func test_Update_Status_Should_Delete_From_And_Add_To_Bin() {
        test_Fillup_Collection()
        
        var objectClone = object3
        objectClone.status = .hot
        
        tester.testElementIsAddedAtAndDeletedFrom(element: objectClone,
                                                  at: IndexPath(row: 0, section: 1),
                                                  from: IndexPath(row: 2, section: 0))
    }
}

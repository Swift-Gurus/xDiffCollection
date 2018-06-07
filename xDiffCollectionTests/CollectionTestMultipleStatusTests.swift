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
    
    var myCollection : DiffCollection<CollectionTestObjectMock>?
    
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
        
        myCollection = DiffCollection(filters: [f1,f2])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Fillup_Collection() {
        _ = myCollection!.update(element: object1)
        _ = myCollection!.update(element: object2)
        _ = myCollection!.update(element: object3)
        _ = myCollection!.update(element: object4)
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object1)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 1, section: 0)), object2)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 2, section: 0)), object3)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 3, section: 0)), object4)
    }
    
    func test_Changing_Status_Within_Same_Bucket_Should_Update_Element() {
        test_Fillup_Collection()
        
        var objectClone = object3
        objectClone.status = .old
        
        let resp = myCollection!.update(element: objectClone)
        XCTAssert(resp.added.count == 0)
        XCTAssertEqual(resp.updated, [IndexPath(row: 2, section: 0)])
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object1)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 1, section: 0)), object2)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 2, section: 0)), objectClone)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 3, section: 0)), object4)
    }
    
    func test_Update_Status_Should_Delete_From_And_Add_To_Bin() {
        test_Fillup_Collection()
        
        var objectClone = object3
        objectClone.status = .hot
        
        let resp = myCollection!.update(element: objectClone)
        XCTAssertEqual(resp.added,[IndexPath(row: 0, section: 1)])
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted,[IndexPath(row: 2, section: 0)])
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 1)), objectClone)
    }
}

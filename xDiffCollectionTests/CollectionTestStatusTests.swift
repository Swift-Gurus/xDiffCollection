//
//  CollectionTestStatusTests.swift
//  CollectionTestTests
//
//  Created by Esteban Garro on 2018-06-05.
//  Copyright © 2018 transcriptics. All rights reserved.
//

import XCTest
@testable import xDiffCollection

fileprivate let object1 = CollectionTestObjectMock(value:"apple")
fileprivate let object2 = CollectionTestObjectMock(value:"ansi")
fileprivate let object3 = CollectionTestObjectMock(value:"bacon")
fileprivate let object4 = CollectionTestObjectMock(value:"cocoon")

class CollectionTestStatusTests: XCTestCase {
    
    
    var myCollection : DiffCollection<CollectionTestObjectMock>?
    
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
        
        myCollection = DiffCollection(filters: [f1,f2,f3,f4])
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

    func test_Update_Element_That_Matches_No_Filter_Should_Return_Three_Empty_Arrays() {
        test_Fillup_Collection()
        
        var object = CollectionTestObjectMock(value: "NewObject")
        object.status = .other
        
        let resp = myCollection!.update(element: object)
        XCTAssert(resp.added.count == 0)
        XCTAssert(resp.updated.count == 0)
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object1)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 1, section: 0)), object2)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 2, section: 0)), object3)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 3, section: 0)), object4)
    }
    
    func test_Update_Status_Should_Delete_From_And_Add_To_Bin() {
        test_Fillup_Collection()
        
        var objectClone = object3
        objectClone.status = .old
        
        var resp = myCollection!.update(element: objectClone)
        XCTAssertEqual(resp.added, [IndexPath(row: 0, section: 1)])
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted, [IndexPath(row: 2, section: 0)])

        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 1)), objectClone)
        
        
        objectClone.status = .hot
        resp = myCollection!.update(element: objectClone)
        XCTAssertEqual(resp.added, [IndexPath(row: 0, section: 2)])
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted, [IndexPath(row: 0, section: 1)])
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 2)), objectClone)
    }

    func test_Delete_Non_Existing_Item_Should_Return_Three_Empty_Arrays() {
        test_Fillup_Collection()
        
        let object = CollectionTestObjectMock(value: "NewObject")
        
        let resp = myCollection!.delete(element: object)
        XCTAssert(resp.added.count == 0)
        XCTAssert(resp.updated.count == 0)
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object1)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 1, section: 0)), object2)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 2, section: 0)), object3)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 3, section: 0)), object4)
    }
}

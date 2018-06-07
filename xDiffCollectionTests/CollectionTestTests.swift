//
//  CollectionTestTests.swift
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

class CollectionTestTests: XCTestCase {
    
    var myCollection : DiffCollection<CollectionTestObjectMock>?
    
    override func setUp() {
        super.setUp()

        let f1 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Starts with a", filter:{ s in
            if(s.value.starts(with: "a")) {
                return true
            }
            return false
        })
        
        let f2 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Starts with b", filter:{ s in
            if(s.value.starts(with: "b")) {
                return true
            }
            return false
        })
        
        let f3 = DiffCollectionFilter<CollectionTestObjectMock>(name: "Starts with c", filter:{ s in
            if(s.value.starts(with: "c")) {
                return true
            }
            return false
        })
        
        myCollection = DiffCollection(filters: [f1,f2,f3])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Fillup_Collection() {
        
        var resp = myCollection!.update(element: object1)
        XCTAssertEqual(resp.added, [IndexPath(row: 0, section: 0)])
        XCTAssert(resp.updated.count == 0)
        XCTAssert(resp.deleted.count == 0)

        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object1)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),1)
        
        resp = myCollection!.update(element: object2)
        XCTAssertEqual(resp.added, [IndexPath(row: 1, section: 0)])
        XCTAssert(resp.updated.count == 0)
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object1)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 1, section: 0)), object2)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),2)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:1),0)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:2),0)
        
        resp = myCollection!.update(element: object3)
        XCTAssertEqual(resp.added, [IndexPath(row: 0, section: 1)])
        XCTAssert(resp.updated.count == 0)
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object1)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 1, section: 0)), object2)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 1)), object3)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),2)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:1),1)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:2),0)
        
        resp = myCollection!.update(element: object4)
        XCTAssertEqual(resp.added, [IndexPath(row: 0, section: 2)])
        XCTAssert(resp.updated.count == 0)
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object1)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 1, section: 0)), object2)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 1)), object3)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 2)), object4)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),2)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:1),1)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:2),1)
    }

    func test_Deleting_From_Collection() {
        test_Fillup_Collection()
        
        var resp = myCollection!.delete(element: object1)
        XCTAssert(resp.added.count == 0)
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted, [IndexPath(row: 0, section: 0)])
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object2)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 1)), object3)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 2)), object4)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),1)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:1),1)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:2),1)
        
        resp = myCollection!.delete(element: object3)
        XCTAssert(resp.added.count == 0)
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted, [IndexPath(row: 0, section: 1)])
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object2)
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 2)), object4)
        XCTAssertNil(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),1)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:1),0)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:2),1)
        
        
        resp = myCollection!.delete(element: object4)
        XCTAssert(resp.added.count == 0)
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted, [IndexPath(row: 0, section: 2)])
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)), object2)
        XCTAssertNil(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),1)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:1),0)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:2),0)
        
        resp = myCollection!.delete(element: object2)
        XCTAssert(resp.added.count == 0)
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted, [IndexPath(row: 0, section: 0)])
        
        XCTAssertNil(myCollection!.element(atIndexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),0)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:1),0)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:2),0)
    }

    func test_Update_Collection() {
        test_Fillup_Collection()
        
        var objectClone = object2
        objectClone.status = .cold
        
        let resp = myCollection!.update(element: objectClone)
        XCTAssert(resp.added.count == 0)
        XCTAssertEqual(resp.updated, [IndexPath(row: 1, section: 0)])
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection!.element(atIndexPath: IndexPath(row: 1, section: 0)), objectClone)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:0),2)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:1),1)
        XCTAssertEqual(myCollection!.numberOfElements(inSection:2),1)
    }
}

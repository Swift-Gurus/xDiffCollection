//
//  CollectionTestTests.swift
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

class CollectionTestTests: XCTestCase {
    var tester : DiffCollectionTester! = nil
        
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
        
        tester = DiffCollectionTester(collection:DiffCollection(filters: [f1,f2,f3]))
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
        tester.testElementIsAddedAt(indexPath:IndexPath(row:0, section:1),
                                             element:object3)
        tester.testElementIsAddedAt(indexPath:IndexPath(row:0, section:2),
                                             element:object4)
    }

    func test_Deleting_From_Collection() {
        test_Fillup_Collection()
        
        tester.testElementIsDeletedFrom(indexPath:IndexPath(row:0, section:0),
                                        element:object1)
        tester.testElementIsDeletedFrom(indexPath:IndexPath(row:0, section:1),
                                        element:object3)
        tester.testElementIsDeletedFrom(indexPath:IndexPath(row:0, section:2),
                                        element:object4)
        tester.testElementIsDeletedFrom(indexPath:IndexPath(row:0, section:0),
                                        element:object2)        
    }

    func test_Update_Collection() {
        test_Fillup_Collection()
        
        var objectClone = object2
        objectClone.status = .cold
        
        tester.testElementIsUpdatedAt(indexPath:IndexPath(row:1, section:0),
                                      element:objectClone)
    }
}

//
//  DiffCollectionTester.swift
//  xDiffCollectionTests
//
//  Created by Esteban Garro on 2018-06-11.
//  Copyright © 2018 transcriptics. All rights reserved.
//

import Foundation
import XCTest
@testable import xDiffCollection



final class DiffCollectionTester {
    var myCollection : DiffCollection<CollectionTestObjectMock>
    
    init(collection:DiffCollection<CollectionTestObjectMock>) {
        self.myCollection = collection
    }
    
    
    
    func testElementIsAddedAtAndDeletedFrom(element     object:CollectionTestObjectMock,
                                            at     atIndexPath:IndexPath,
                                            from fromIndexPath:IndexPath,
                                            file: StaticString = #file,
                                            line: UInt = #line) {
        
        var currentNumberOfElements : [Int] = []
        let numberOfSections = myCollection.numberOfSections()
        for i in 0..<numberOfSections {
            currentNumberOfElements.append(myCollection.numberOfElements(inSection: i))
        }
        
        let resp = myCollection.update(element: object)
        XCTAssertEqual(resp.added, [atIndexPath])
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted, [fromIndexPath])
        
        XCTAssertEqual(myCollection.element(atIndexPath: atIndexPath), object)
        
        for i in 0..<numberOfSections {
            if (atIndexPath.section == i) {
                XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i]+1)
            }
            if (fromIndexPath.section == i) {
                XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i]-1)
            }
        }
    }
    
    func testElementOperationMatchingNoFilterLeavesCollectionUnchanged(element object:CollectionTestObjectMock,
                                                                       isDelete: Bool = false,
                                                                       file: StaticString = #file,
                                                                       line: UInt = #line) {
    
        var (currentMatrix, _) = self.returnCurrentState()
        let numberOfBins = myCollection.numberOfSections()
        
        var resp : DiffCollectionResult? = nil
        if isDelete {
            resp = myCollection.delete(element: object)
        } else {
            resp = myCollection.update(element: object)
        }
        
        XCTAssert(resp!.added.count == 0)
        XCTAssert(resp!.updated.count == 0)
        XCTAssert(resp!.deleted.count == 0)
        
        for i in 0..<numberOfBins {
            let numberOfElementsInSection = myCollection.numberOfElements(inSection: i)
            for j in 0..<numberOfElementsInSection {
                XCTAssertEqual(myCollection.element(atIndexPath: IndexPath(row: j, section: i)), currentMatrix[i][j])
            }
        }
    }
    
    func testElementIsAddedAt(indexPath:IndexPath,
                              element object:CollectionTestObjectMock,
                              file: StaticString = #file,
                              line: UInt = #line) {

        var currentNumberOfElements : [Int] = []
        let numberOfSections = myCollection.numberOfSections()
        for i in 0..<numberOfSections {
            currentNumberOfElements.append(myCollection.numberOfElements(inSection: i))
        }
        
        let resp = myCollection.update(element: object)
        XCTAssertEqual(resp.added, [indexPath])
        XCTAssert(resp.updated.count == 0)
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection.element(atIndexPath: indexPath), object)
        
        for i in 0..<numberOfSections {
            if (indexPath.section == i) {
                XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i]+1)
            } else {
                XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i])
            }
        }
    }
    
    func testElementIsUpdatedAt(indexPath:IndexPath,
                                element object:CollectionTestObjectMock,
                                file: StaticString = #file,
                                line: UInt = #line) {
        
        var currentNumberOfElements : [Int] = []
        let numberOfSections = myCollection.numberOfSections()
        for i in 0..<numberOfSections {
            currentNumberOfElements.append(myCollection.numberOfElements(inSection: i))
        }
        
        let resp = myCollection.update(element: object)
        XCTAssert(resp.added.count == 0)
        XCTAssertEqual(resp.updated, [indexPath])
        XCTAssert(resp.deleted.count == 0)
        
        XCTAssertEqual(myCollection.element(atIndexPath: indexPath), object)
        
        for i in 0..<numberOfSections {
            XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i])
        }
    }
    
    func testElementIsDeletedFrom(indexPath:IndexPath,
                                  element object:CollectionTestObjectMock,
                                  file: StaticString = #file,
                                  line: UInt = #line) {
        
        var (currentMatrix, currentNumberOfElements) = self.returnCurrentState()
    
        let resp = myCollection.delete(element: object)
        XCTAssert(resp.added.count == 0)
        XCTAssert(resp.updated.count == 0)
        XCTAssertEqual(resp.deleted, [indexPath])

        let numberOfBins = myCollection.numberOfSections()
        for i in 0..<numberOfBins {
            let numberOfElementsInSection = myCollection.numberOfElements(inSection: i)
            if (indexPath.section == i) {
                for j in 0..<numberOfElementsInSection {
                    if j < indexPath.row {
                        XCTAssertEqual(myCollection.element(atIndexPath: IndexPath(row: j, section: i)), currentMatrix[i][j])
                    } else {
                        XCTAssertEqual(myCollection.element(atIndexPath: IndexPath(row: j, section: i)), currentMatrix[i][j+1])
                    }
                }
            } else {
                for j in 0..<numberOfElementsInSection {
                  XCTAssertEqual(myCollection.element(atIndexPath: IndexPath(row: j, section: i)), currentMatrix[i][j])
                }
            }
        }

        
        for i in 0..<numberOfBins {
            if (indexPath.section == i) {
                XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i]-1)
            } else {
                XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i])
            }
        }
    }
    
    fileprivate func returnCurrentState() -> ([[CollectionTestObjectMock]],[Int]) {
        var currentNumberOfElements : [Int] = []
        var resp : [[CollectionTestObjectMock]] = []
        let numberOfBins = myCollection.numberOfSections()
        for i in 0..<numberOfBins {
            let numberOfElementsInBin = myCollection.numberOfElements(inSection: i)
            currentNumberOfElements.append(numberOfElementsInBin)
            var newBin : [CollectionTestObjectMock] = []
            for j in 0..<numberOfElementsInBin {
                newBin.append(myCollection.element(atIndexPath: IndexPath(row: j, section: i))!)
            }
            resp.append(newBin)
        }
        
        return (resp,currentNumberOfElements)
    }
}

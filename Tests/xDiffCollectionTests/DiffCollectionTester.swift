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
    
    func testElementIsAddedAtAndDeletedFrom(element object: CollectionTestObjectMock,
                                            at atIndexPath: IndexPath,
                                            from fromIndexPath: IndexPath,
                                            file: StaticString = #file,
                                            line: UInt = #line) {
        
        let currentNumberOfElements = myCollection.map({ $0.count })
        
        let resp = myCollection.update(with: object)
        XCTAssertEqual(resp.changes.addedIndexes, [atIndexPath])
        XCTAssert(resp.changes.updatedIndexes.count == 0)
        XCTAssertEqual(resp.changes.removedIndexes, [fromIndexPath])
        
        XCTAssertEqual(myCollection[atIndexPath], object)
        
        for i in 0..<myCollection.count {
            if (atIndexPath.section == i) {
                XCTAssertEqual(myCollection.element(at: i)?.count,currentNumberOfElements[i]+1)
            }
            if (fromIndexPath.section == i) {
                XCTAssertEqual(myCollection.element(at: i)?.count,currentNumberOfElements[i]-1)
            }
        }
    }

    func testElementOperationMatchingNoFilterLeavesCollectionUnchanged(element object: CollectionTestObjectMock,
                                                                       isDelete: Bool = false,
                                                                       file: StaticString = #file,
                                                                       line: UInt = #line) {
    
        var (currentMatrix, _) = self.returnCurrentState()
        let numberOfBins = myCollection.count
        

        let resp = myCollection.update(with: object)

        XCTAssert(resp.changes.updatedIndexes.count == 0, file: file, line: line)
        XCTAssert(resp.changes.removedIndexes.count == 0, file: file, line: line)
        
        for i in 0..<numberOfBins {
            let numberOfElementsInSection = myCollection.numberOfElements(inSection: i)
            for j in 0..<numberOfElementsInSection {
                XCTAssertEqual(myCollection.element(atIndexPath: IndexPath(row: j, section: i)), currentMatrix[i][j])
            }
        }
    }
    
    @discardableResult
    func testAdd(element object:CollectionTestObjectMock,
                            file: StaticString = #file,
                            line: UInt = #line) -> DiffCollectionResult {
        
         let currentNumberOfElements = myCollection.reduce(0, { $0 + $1.count })
         let resp = myCollection.update(with: object)
         let newNumberOfElements = myCollection.reduce(0, { $0 + $1.count })
        
         XCTAssert(newNumberOfElements == currentNumberOfElements + 1, file: file, line: line)
        return resp.changes
    }
    
    func testElementAtIndexPathIsEqualTo(indexPath:IndexPath,
                                         element object: CollectionTestObjectMock,
                                         file: StaticString = #file,
                                         line: UInt = #line) {
    
        let e = myCollection[indexPath.section][indexPath.row]
        XCTAssertEqual(e, object, file: file, line: line)
    }
    
    func testElementIsAddedAt(indexPath:IndexPath,
                              element object: CollectionTestObjectMock,
                              file: StaticString = #file,
                              line: UInt = #line) {

        let numberOfSections = myCollection.count
        let currentNumberOfElements = myCollection.map({ $0.count })

        let resp = myCollection.update(with: object)
        XCTAssertEqual(resp.changes.addedIndexes, [indexPath], file: file, line: line)
        XCTAssert(resp.changes.updatedIndexes.count == 0,file: file, line: line)
        XCTAssert(resp.changes.removedIndexes.count == 0,file: file, line: line)
        
        XCTAssertEqual(myCollection.element(atIndexPath: indexPath), object,file: file, line: line)
        
        
        
        for i in 0..<numberOfSections {
            if (indexPath.section == i) {
                XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i]+1,file: file, line: line)
            } else {
                XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i],file: file, line: line)
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
        
        let resp = myCollection.update(with: object)
        XCTAssert(resp.changes.addedIndexes.count == 0, file: file, line: line)
        XCTAssertEqual(resp.changes.updatedIndexes, [indexPath], file: file, line: line)
        XCTAssert(resp.changes.removedIndexes.count == 0, file: file, line: line)
        
        XCTAssertEqual(myCollection[indexPath], object, file: file, line: line)
        
        for i in 0..<numberOfSections {
            XCTAssertEqual(myCollection.numberOfElements(inSection:i),currentNumberOfElements[i])
        }
    }
 
    fileprivate func returnCurrentState() -> ([[CollectionTestObjectMock]],[Int]) {
        var currentNumberOfElements : [Int] = []
        var resp : [[CollectionTestObjectMock]] = []
        let numberOfBins = myCollection.count
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

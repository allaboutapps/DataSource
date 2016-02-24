//
//  DataSourceTests.swift
//  DataSourceTests
//
//  Created by Matthias Buchetics on 28/08/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import XCTest
import UIKit

@testable import DataSource

class DataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNumberOfSections() {
        let dataSource1 = singleSectionDataSource()
        XCTAssertEqual(dataSource1.sections.count, 1, "number of sections = 1")
        
        let dataSource2 = multipleSectionDataSource()
        XCTAssertEqual(dataSource2.sections.count, 2, "number of sections = 2")
    }
    
    func testNumberOfRows() {
        let dataSource1 = singleSectionDataSource()
        XCTAssertEqual(dataSource1.sectionAtIndex(0).numberOfRows, 4, "number of rows = 4")
        
        let dataSource2 = multipleSectionDataSource()
        XCTAssertEqual(dataSource2.sectionAtIndex(1).numberOfRows, 3, "number of rows = 3")
    }
    
    func testFirstAndLastSection() {
        let dataSource = twoEmpySectionDataSource()
        
        let section1 = dataSource.sectionAtIndex(0)
        let section2 = dataSource.sectionAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
        
        XCTAssertEqual(dataSource.firstSection?.title, section1.title, "first section")
        XCTAssertEqual(dataSource.lastSection?.title, section2.title, "last section")
    }
    
    func testMutatingSections() {
        var dataSource = twoEmpySectionDataSource()
        let section1 = dataSource.sectionAtIndex(0)
        let section2 = dataSource.sectionAtIndex(1)
        
        // remove
        dataSource.removeSectionAtIndex(0)
        XCTAssertEqual(dataSource.numberOfSections, 1, "number of sections = 1")
        
        // insert
        dataSource.insertSection(section1, index: 1)
        XCTAssertEqual(dataSource.numberOfSections, 2, "number of sections = 2")
        
        // set
        dataSource.setSection(section1, index: 0)
        dataSource.setSection(section2, index: 1)
        XCTAssertEqual(dataSource.sectionAtIndex(0).title, section1.title, "")
        XCTAssertEqual(dataSource.sectionAtIndex(1).title, section2.title, "")
        
        // append section
        dataSource.appendSection(section1)
        XCTAssertEqual(dataSource.numberOfSections, 3, "number of sections = 3")
        XCTAssertEqual(dataSource.lastSection?.title, section1.title, "")
        
        // append dataSource
        dataSource.appendDataSource(twoEmpySectionDataSource())
        XCTAssertEqual(dataSource.numberOfSections, 5, "number of sections = 5")
        XCTAssertEqual(dataSource.lastSection?.title, section2.title, "")
    }
    
    func testRowCreatorAndCountClosures() {
        let dataSource = DataSource(Section(rowCountClosure: { () -> Int in
            return 1
            }, rowCreatorClosure: { (rowIndex) -> Row<Any> in
                return Row(identifier: RowIdentifier.Text.rawValue, data: "a")
        }))
        
        XCTAssertEqual(dataSource.sectionAtIndex(0).numberOfRows, 1, "number of rows = 1")
        
        let row = dataSource.rowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(row.anyData as? String, "a", "row.anyData = a")
    }
    
    func testSectionHasTitle() {
        let sectionWithTitle = Section<Any>(title: "Title", rows: [])
        let sectionWithoutTitle = Section<Any>(title: nil, rows: [])
        let sectionWithEmptyTitle = Section<Any>(title: "", rows: [])
        
        XCTAssertEqual(sectionWithTitle.hasTitle, true, "section.hasTitle = true")
        XCTAssertEqual(sectionWithoutTitle.hasTitle, false, "section.hasTitle = false")
        XCTAssertEqual(sectionWithEmptyTitle.hasTitle, false, "section.hasTitle = false")
    }
    
    func testAlternativeInit() {
        let section1 = Section<Any>(title: "Section", rows: [])
        let dataSource1 = DataSource(section1)
        
        XCTAssertEqual(dataSource1.numberOfSections, 1, "number of sections = 1")
        
        let dataSources = [singleSectionDataSource(), singleSectionDataSource()]
        let dataSource2 = DataSource(dataSources: dataSources)
        
        XCTAssertEqual(dataSource2.numberOfSections, 2, "number of sections = 2")
    }
    
    func testRowDataStrings() {
        let dataSource1 = singleSectionDataSource()
        
        XCTAssertEqual(dataSource1.sectionAtIndex(0).numberOfRows, 4, "number of rows")
        
        let row0: Row<String> = dataSource1.rowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(row0.data, "a", "row_0_0: 1")
        
        let row1: Row<String> = dataSource1.rowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertEqual(row1.data, "b", "row_0_1: 2")
        
        let row2: Row<String> = dataSource1.rowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        XCTAssertEqual(row2.data, "c", "row_0_2: 3")
        
        let row3: Row<String> = dataSource1.rowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
        XCTAssertEqual(row3.data, "d", "row_0_3: 4")
    }
    
}

extension DataSourceTests {
    
    func singleSectionDataSource() -> DataSource {
        return DataSource([
            Section(rows: [
                Row(identifier: "Text", data: "a"),
                Row(identifier: "Text", data: "b"),
                Row(identifier: "Text", data: "c"),
                Row(identifier: "Text", data: "d"),
                ])
            ])
    }
    
    func multipleSectionDataSource() -> DataSource {
        return DataSource([
            Section(rows: [
                Row(identifier: "Text", data: "0a"),
                Row(identifier: "Text", data: "0b"),
                Row(identifier: "Text", data: "0c"),
                ]),
            Section(rows: [
                Row(identifier: "Text", data: "1a"),
                Row(identifier: "Text", data: "2b"),
                Row(identifier: "Text", data: "3c"),
                ])
            ])
    }
    
    func twoEmpySectionDataSource() -> DataSource {
        let section1 = Section<Any>(title: "First", rows: [])
        let section2 = Section<Any>(title: "Last", rows: [])
        
        return DataSource([section1, section2])
    }
}

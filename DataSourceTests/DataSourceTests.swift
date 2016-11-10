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
        XCTAssertEqual(dataSource1.numberOfSections, 1, "number of sections = 1")
        
        let dataSource2 = multipleSectionDataSource()
        XCTAssertEqual(dataSource2.numberOfSections, 2, "number of sections = 2")
    }
    
    func testNumberOfRows() {
        let dataSource1 = singleSectionDataSource()
        XCTAssertEqual(dataSource1.section(at: 0).numberOfRows, 4, "number of rows = 4")
        
        let dataSource2 = multipleSectionDataSource()
        XCTAssertEqual(dataSource2.section(at: 1).numberOfRows, 3, "number of rows = 3")
    }
    
    func testFirstAndLastSection() {
        let dataSource = twoEmpySectionDataSource()
        
        let section1 = dataSource.section(at: 0)
        let section2 = dataSource.section(at: IndexPath(row: 0, section: 1))
        
        XCTAssertEqual(dataSource.firstSection?.title, section1.title, "first section")
        XCTAssertEqual(dataSource.lastSection?.title, section2.title, "last section")
    }
    
    func testMutatingSections() {
        var dataSource = twoEmpySectionDataSource()
        let section1 = dataSource.section(at: 0)
        let section2 = dataSource.section(at: 1)
        
        // remove
        dataSource.removeSection(at: 0)
        XCTAssertEqual(dataSource.numberOfSections, 1, "number of sections = 1")
        
        // insert
        dataSource.insert(section: section1, at: 1)
        XCTAssertEqual(dataSource.numberOfSections, 2, "number of sections = 2")
        
        // set
        dataSource.replace(section: section1, at: 0)
        dataSource.replace(section: section2, at: 1)
        XCTAssertEqual(dataSource.section(at: 0).title, section1.title, "")
        XCTAssertEqual(dataSource.section(at: 1).title, section2.title, "")
        
        // append section
        dataSource.append(section: section1)
        XCTAssertEqual(dataSource.numberOfSections, 3, "number of sections = 3")
        XCTAssertEqual(dataSource.lastSection?.title, section1.title, "")
        
        // append dataSource
        dataSource.append(dataSource: twoEmpySectionDataSource())
        XCTAssertEqual(dataSource.numberOfSections, 5, "number of sections = 5")
        XCTAssertEqual(dataSource.lastSection?.title, section2.title, "")
    }
    
    func testRowCreatorAndCountClosures() {
        let dataSource = DataSource(section: Section(rowCountClosure: { () -> Int in
            return 1
        }, rowCreatorClosure: { (rowIndex) in
            return Row(identifier: RowIdentifier.text, data: "a")
        }))
        
        XCTAssertEqual(dataSource.section(at: 0).numberOfRows, 1, "number of rows = 1")
        
        let row = dataSource.row(at: IndexPath(row: 0, section: 0))
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
        let dataSource1 = DataSource(section: section1)
        
        XCTAssertEqual(dataSource1.numberOfSections, 1, "number of sections = 1")
        
        let dataSources = [singleSectionDataSource(), singleSectionDataSource()]
        let dataSource2 = DataSource(dataSources: dataSources)
        
        XCTAssertEqual(dataSource2.numberOfSections, 2, "number of sections = 2")
    }
    
    func testRowDataStrings() {
        let dataSource1 = singleSectionDataSource()
        
        XCTAssertEqual(dataSource1.section(at: 0).numberOfRows, 4, "number of rows")
        
        let row0: Row<String> = dataSource1.row(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(row0.data, "a", "row_0_0: 1")
        
        let row1: Row<String> = dataSource1.row(at: IndexPath(row: 1, section: 0))
        XCTAssertEqual(row1.data, "b", "row_0_1: 2")
        
        let row2: Row<String> = dataSource1.row(at: IndexPath(row: 2, section: 0))
        XCTAssertEqual(row2.data, "c", "row_0_2: 3")
        
        let row3: Row<String> = dataSource1.row(at: IndexPath(row: 3, section: 0))
        XCTAssertEqual(row3.data, "d", "row_0_3: 4")
    }
}

// MARK: - Convenience

extension DataSourceTests {
    
    func singleSectionDataSource() -> DataSource {
        return DataSource(section:
            Section(rows: [
                Row(identifier: "Text", data: "a"),
                Row(identifier: "Text", data: "b"),
                Row(identifier: "Text", data: "c"),
                Row(identifier: "Text", data: "d"),
            ])
        )
    }
    
    func multipleSectionDataSource() -> DataSource {
        return DataSource(sections: [
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
        
        return DataSource(sections: [section1, section2])
    }
}

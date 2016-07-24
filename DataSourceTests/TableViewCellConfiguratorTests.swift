//
//  TableViewCellConfiguratorTests.swift
//  Example
//
//  Created by Marcel Zanoni on 22/02/16.
//  Copyright © 2016 aaa - all about apps GmbH. All rights reserved.
//

import XCTest
@testable import DataSource

class TableViewCellConfiguratorTests: XCTestCase {
    
    let person1 = Person(firstname: "Matthias", lastname: "Buchetics")
    let person2 = Person(firstname: "Marcel", lastname: "Zanoni")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTableViewDataSourceSectionTitle() {
        let tableViewDataSource = personTableViewDataSource()
        
        let sectionTitle = tableViewDataSource.sectionAtIndex(0).title
        XCTAssertEqual(sectionTitle, "Persons", "section title = Persons")
    }
    
    func testSingleRowTypeSectionTableViewDataSource() {
        let tableViewDataSource = personTableViewDataSource()
        
        let row = tableViewDataSource.rowAtIndexPath(IndexPath(forRow: 0, inSection: 0))
        
        let configurator = tableViewDataSource.configuratorForRowIdentifier(RowIdentifier.Person.rawValue)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: RowIdentifier.Person.rawValue)
        
        configurator?.configureRow(row, cell: cell, indexPath: IndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(cell.textLabel?.text, person1.firstname, "cell.textLabel.text = Matthias")
        XCTAssertEqual(cell.detailTextLabel?.text, person1.lastname, "cell.detailTextLabel.text = Buchetics")
    }
    
    func testMixedRowTypeSectionTableViewDataSource() {
        let tableViewDataSource = personAndStringsTableViewDataSource()
        
        let personRow = tableViewDataSource.rowAtIndexPath(IndexPath(forRow: 0, inSection: 0))
        let personConfigurator = tableViewDataSource.configuratorForRowIdentifier(RowIdentifier.Person.rawValue)
        
        let personCell = UITableViewCell(style: .subtitle, reuseIdentifier: RowIdentifier.Person.rawValue)
        
        personConfigurator?.configureRow(personRow, cell: personCell, indexPath: IndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(personCell.textLabel?.text, person1.firstname, "cell.textLabel.text = Matthias")
        XCTAssertEqual(personCell.detailTextLabel?.text, person1.lastname, "cell.detailTextLabel.text = Buchetics")
        
        let stringRow = tableViewDataSource.rowAtIndexPath(IndexPath(forRow: 1, inSection: 0))
        let stringConfigurator = tableViewDataSource.configuratorForRowIdentifier(RowIdentifier.Text.rawValue)
        
        let stringCell = UITableViewCell(style: .default, reuseIdentifier: RowIdentifier.Text.rawValue)
        
        stringConfigurator?.configureRow(stringRow, cell: stringCell, indexPath: IndexPath(forRow: 1, inSection: 0))
        XCTAssertEqual(stringCell.textLabel?.text, "a", "cell.textLabel.text = a")
    }
    
    func testRowAndCellIdentifierTableViewDataSource() {
        let dataSource = personAndStringDataSource()
        let cellIdentifier = "Text"
        
        let tableViewDataSource = TableViewDataSource(dataSource: dataSource, configurators: [
            TableViewCellConfigurator(rowIdentifier: RowIdentifier.Person.rawValue, cellIdentifier: cellIdentifier, configure: { (person: Person, cell: UITableViewCell, indexPath: IndexPath) in
                cell.textLabel?.text = "\(person.firstname) \(person.lastname)"
            }),
            TableViewCellConfigurator(rowIdentifier: RowIdentifier.Text.rawValue, cellIdentifier: cellIdentifier, configure: { (text: String, cell: UITableViewCell, indexPath: IndexPath) in
                cell.textLabel?.text = text
            })
            ])
        
        let personIndexPath = IndexPath(row: 0, section: 0)
        let stringIndexPath = IndexPath(row: 1, section: 0)
        
        let tableView = UITableView()
        tableView.dataSource = tableViewDataSource
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let personCell = tableViewDataSource.tableView(tableView, cellForRowAtIndexPath: personIndexPath)
        XCTAssertEqual(personCell.textLabel?.text, "\(person1.firstname) \(person1.lastname)", "cell.textLabel.text = Matthias Buchetics")
        
        let stringCell = tableViewDataSource.tableView(tableView, cellForRowAtIndexPath: stringIndexPath)
        XCTAssertEqual(stringCell.textLabel?.text, "a", "cell.textLabel.text = a")
    }
}

// MARK: - Convenience

extension TableViewCellConfiguratorTests {
    
    func personDataSource() -> DataSource {
        return DataSource([
            Section<Person> (title: "Persons", rowIdentifier: RowIdentifier.Person.rawValue, rows: [
                person1,
                person2
                ])
            ])
    }
    
    func personAndStringDataSource() -> DataSource {
        return DataSource([
            Section<Any> (title: "Mixed", rows: [
                Row(identifier: RowIdentifier.Person.rawValue, data: person1),
                Row(identifier: RowIdentifier.Text.rawValue, data: "a")
                ])
            ])
    }
    
    func personTableViewDataSource() -> TableViewDataSource {
        let dataSource = personDataSource()
        
        return TableViewDataSource(dataSource: dataSource, configurator:
            TableViewCellConfigurator<Person, UITableViewCell>(RowIdentifier.Person.rawValue) { (person: Person, cell: UITableViewCell, _) in
                cell.textLabel?.text = person.firstname
                cell.detailTextLabel?.text = person.lastname
            })
    }
    
    func personAndStringsTableViewDataSource() -> TableViewDataSource {
        let dataSource = personAndStringDataSource()
        
        return TableViewDataSource(dataSource: dataSource, configurators: [
            TableViewCellConfigurator<Person, UITableViewCell>(RowIdentifier.Person.rawValue) { (person: Person, cell: UITableViewCell, _) in
                cell.textLabel?.text = person.firstname
                cell.detailTextLabel?.text = person.lastname
            },
            TableViewCellConfigurator<String, UITableViewCell>(RowIdentifier.Text.rawValue) { (title: String, cell: UITableViewCell, _) in
                cell.textLabel?.text = title
            }
            ])
    }
}

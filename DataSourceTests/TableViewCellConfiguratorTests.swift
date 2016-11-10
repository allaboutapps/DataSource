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
        
        let sectionTitle = tableViewDataSource.section(at: 0).title
        XCTAssertEqual(sectionTitle, "Persons", "section title = Persons")
    }
    
    func testSingleRowTypeSectionTableViewDataSource() {
        let tableViewDataSource = personTableViewDataSource()
        
        let row = tableViewDataSource.row(at: IndexPath(row: 0, section: 0))
        
        let configurator = tableViewDataSource.configurator(for: RowIdentifier.person)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: RowIdentifier.person)
        
        configurator?.configure(row: row, cell: cell, indexPath: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.textLabel?.text, person1.firstname, "cell.textLabel.text = Matthias")
        XCTAssertEqual(cell.detailTextLabel?.text, person1.lastname, "cell.detailTextLabel.text = Buchetics")
    }
    
    func testMixedRowTypeSectionTableViewDataSource() {
        let tableViewDataSource = personAndStringsTableViewDataSource()
        
        let personRow = tableViewDataSource.row(at: IndexPath(row: 0, section: 0))
        let personConfigurator = tableViewDataSource.configurator(for: RowIdentifier.person)
        
        let personCell = UITableViewCell(style: .subtitle, reuseIdentifier: RowIdentifier.person)
        
        personConfigurator?.configure(row: personRow, cell: personCell, indexPath: IndexPath(row: 0, section: 0))
        XCTAssertEqual(personCell.textLabel?.text, person1.firstname, "cell.textLabel.text = Matthias")
        XCTAssertEqual(personCell.detailTextLabel?.text, person1.lastname, "cell.detailTextLabel.text = Buchetics")
        
        let stringRow = tableViewDataSource.row(at: IndexPath(row: 1, section: 0))
        let stringConfigurator = tableViewDataSource.configurator(for: RowIdentifier.text)
        let stringCell = UITableViewCell(style: .default, reuseIdentifier: RowIdentifier.text)

        stringConfigurator?.configure(row: stringRow, cell: stringCell, indexPath: IndexPath(row: 1, section: 0))
        XCTAssertEqual(stringCell.textLabel?.text, "a", "cell.textLabel.text = a")
    }
    
    func testRowAndCellIdentifierTableViewDataSource() {
        let dataSource = personAndStringDataSource()
        let cellIdentifier = "Text"
        
        let tableViewDataSource = TableViewDataSource(dataSource: dataSource, configurators: [
            TableViewCellConfigurator(rowIdentifier: RowIdentifier.person, cellIdentifier: cellIdentifier, configure: { (person: Person, cell: UITableViewCell, indexPath: IndexPath) in
                cell.textLabel?.text = "\(person.firstname) \(person.lastname)"
            }),
            TableViewCellConfigurator(rowIdentifier: RowIdentifier.text, cellIdentifier: cellIdentifier, configure: { (text: String, cell: UITableViewCell, indexPath: IndexPath) in
                cell.textLabel?.text = text
            })
            ])
        
        let personIndexPath = IndexPath(row: 0, section: 0)
        let stringIndexPath = IndexPath(row: 1, section: 0)
        
        let tableView = UITableView()
        tableView.dataSource = tableViewDataSource
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let personCell = tableViewDataSource.tableView(tableView, cellForRowAt: personIndexPath)
        XCTAssertEqual(personCell.textLabel?.text, "\(person1.firstname) \(person1.lastname)", "cell.textLabel.text = Matthias Buchetics")
        
        let stringCell = tableViewDataSource.tableView(tableView, cellForRowAt: stringIndexPath)
        XCTAssertEqual(stringCell.textLabel?.text, "a", "cell.textLabel.text = a")
    }
}

// MARK: - Convenience

extension TableViewCellConfiguratorTests {
    
    func personDataSource() -> DataSource {
        return DataSource(sections: [
            Section<Person> (title: "Persons", rowIdentifier: RowIdentifier.person, rows: [
                person1,
                person2
            ])
        ])
    }
    
    func personAndStringDataSource() -> DataSource {
        let rows: [Row<Any>] =  [
            Row(identifier: RowIdentifier.person, data: person1),
            Row(identifier: RowIdentifier.text, data: "a")
        ]

        return DataSource(sections: [
            Section(title: "Mixed", rows: rows)
        ])
    }
    
    func personTableViewDataSource() -> TableViewDataSource {
        let dataSource = personDataSource()
        
        return TableViewDataSource(dataSource: dataSource, configurator:
            TableViewCellConfigurator<Person, UITableViewCell>(identifier: RowIdentifier.person) { (person: Person, cell: UITableViewCell, _) in
                cell.textLabel?.text = person.firstname
                cell.detailTextLabel?.text = person.lastname
            })
    }
    
    func personAndStringsTableViewDataSource() -> TableViewDataSource {
        let dataSource = personAndStringDataSource()
        
        return TableViewDataSource(dataSource: dataSource, configurators: [
            TableViewCellConfigurator<Person, UITableViewCell>(identifier: RowIdentifier.person) { (person: Person, cell: UITableViewCell, _) in
                cell.textLabel?.text = person.firstname
                cell.detailTextLabel?.text = person.lastname
            },
            TableViewCellConfigurator<String, UITableViewCell>(identifier: RowIdentifier.text) { (title: String, cell: UITableViewCell, _) in
                cell.textLabel?.text = title
            }
            ])
    }
}

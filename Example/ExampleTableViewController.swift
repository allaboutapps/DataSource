//
//  ExampleTableViewController
//  Example
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

enum Identifiers: String {
    case TextCell
    case PersonCell
    case ButtonCell
}

enum Button: String {
    case Add
    case Remove
}

class ExampleTableViewController: UITableViewController {
    var tableDataSource: TableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(Identifiers.ButtonCell.rawValue)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.dataSource = tableDataSource
        tableView.reloadData()
    }
    
    // MARK: Examples
    
    /// demonstrates various ways to setup the same simple data source
    func setupExample1() {
        let dataSource1 = DataSource([
            Section(rows: [
                Row(identifier: Identifiers.TextCell.rawValue, data: "a"),
                Row(identifier: Identifiers.TextCell.rawValue, data: "b"),
                Row(identifier: Identifiers.TextCell.rawValue, data: "c"),
                Row(identifier: Identifiers.TextCell.rawValue, data: "d"),
            ])
        ])
        
        let dataSource2 = DataSource([
            Section(rowIdentifier: Identifiers.TextCell.rawValue, rows: ["a", "b", "c", "d"])
        ])

        let dataSource3 = ["a", "b", "c", "d"]
            .toDataSourceSection(Identifiers.TextCell.rawValue)
            .toDataSource()
        
        let dataSource4 = ["a", "b", "c", "d"].toDataSource(Identifiers.TextCell.rawValue)
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource1,
            configurator: TableViewCellConfigurator(Identifiers.TextCell.rawValue) { (title: String, cell: UITableViewCell, _) in
                cell.textLabel?.text = title
            })
        
        debugPrint(dataSource1)
        debugPrint(dataSource2)
        debugPrint(dataSource3)
        debugPrint(dataSource4)
    }
    
    /// heterogenous data source with different row/cell types
    func setupExample2() {
        let dataSource = DataSource([
            Section(title: "B", rowIdentifier: Identifiers.PersonCell.rawValue, rows: [
                Person(firstName: "Matthias", lastName: "Buchetics"),
                ]),
            Section(title: "M", rowIdentifier: Identifiers.PersonCell.rawValue, rows: [
                Person(firstName: "Hugo", lastName: "Maier"),
                Person(firstName: "Max", lastName: "Mustermann"),
                ]),
            Section(title: "Strings", rowIdentifier: Identifiers.TextCell.rawValue, rows: [
                "some text",
                "another text"
                ]),
            Section(rowIdentifier: Identifiers.ButtonCell.rawValue, rows: [
                Button.Add,
                Button.Remove
                ]),
            ])
        
        debugPrint(dataSource)
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource,
            configurators: [
                TableViewCellConfigurator(Identifiers.PersonCell.rawValue) { (person: Person, cell: PersonCell, _) in
                    cell.firstNameLabel?.text = person.firstName
                    cell.lastNameLabel?.text = person.lastName
                },
                TableViewCellConfigurator(Identifiers.TextCell.rawValue) { (title: String, cell: UITableViewCell, _) in
                    cell.textLabel?.text = title
                },
                TableViewCellConfigurator(Identifiers.ButtonCell.rawValue) { (button: Button, cell: ButtonCell, _) in
                    switch (button) {
                    case .Add:
                        cell.titleLabel?.text = "Add"
                        cell.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.2, alpha: 0.8)
                    case .Remove:
                        cell.titleLabel?.text = "Remove"
                        cell.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
                    }
                },
            ])
    }
    
    /// example how to combine and modify existing data sources
    func setupExample3() {
        let dataSource1 = DataSource([
            Section(title: "B", rowIdentifier: Identifiers.PersonCell.rawValue, rows: [
                Person(firstName: "Matthias", lastName: "Buchetics"),
                ]),
            Section(title: "M", rowIdentifier: Identifiers.PersonCell.rawValue, rows: [
                Person(firstName: "Hugo", lastName: "Maier"),
                Person(firstName: "Max", lastName: "Mustermann"),
                ]),
            ])
        
        let dataSource2 = DataSource(
            Section(title: "Strings", rowIdentifier: Identifiers.TextCell.rawValue, rows: ["some text", "another text"]))
        
        var compoundDataSource = DataSource(dataSources: [dataSource1, dataSource2])
        
        compoundDataSource.appendDataSource(dataSource2)
        compoundDataSource.appendDataSource(dataSource1)
        compoundDataSource.removeSectionAtIndex(1)
        
        debugPrint(compoundDataSource)
        
        tableDataSource = TableViewDataSource(
            dataSource: compoundDataSource,
            configurators: [
                TableViewCellConfigurator(Identifiers.PersonCell.rawValue) { (person: Person, cell: PersonCell, _) in
                    cell.firstNameLabel?.text = person.firstName
                    cell.lastNameLabel?.text = person.lastName
                },
                TableViewCellConfigurator(Identifiers.TextCell.rawValue) { (title: String, cell: UITableViewCell, _) in
                    cell.textLabel?.text = title
                }
            ])
    }
    
    /// shows how to transform a dictionary into data source
    func setupExample4() {
        let data = [
            "section 1": ["a", "b", "c"],
            "section 2": ["d", "e", "f"],
            "section 3": ["g", "h", "i"],
        ]
        
        let dataSource = data.toDataSource(Identifiers.TextCell.rawValue, orderedKeys: data.keys.sort())
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource,
            configurator: TableViewCellConfigurator(Identifiers.TextCell.rawValue) { (title: String, cell: UITableViewCell, _) in
                cell.textLabel?.text = title
            })
    }
    
    /// example with an empty section
    func setupExample5() {
        let dataSource = DataSource([
            Section(title: "B", rowIdentifier: Identifiers.PersonCell.rawValue, rows: [
                Person(firstName: "Matthias", lastName: "Buchetics"),
                ]),
            Section(title: "M", rowIdentifier: Identifiers.PersonCell.rawValue, rows: [
                Person(firstName: "Hugo", lastName: "Maier"),
                Person(firstName: "Max", lastName: "Mustermann"),
                ]),
            Section(title: "Empty Section", rowIdentifier: Identifiers.TextCell.rawValue, rows: Array<String>()),
            Section(title: "Strings", rowIdentifier: Identifiers.TextCell.rawValue, rows: ["some text", "another text"]),
            ])
        
        debugPrint(dataSource)
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource,
            configurators: [
                TableViewCellConfigurator(Identifiers.PersonCell.rawValue) { (person: Person, cell: PersonCell, _) in
                    cell.firstNameLabel?.text = person.firstName
                    cell.lastNameLabel?.text = person.lastName
                },
                TableViewCellConfigurator(Identifiers.TextCell.rawValue) { (title: String, cell: UITableViewCell, _) in
                    cell.textLabel?.text = title
                },
            ])
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = tableDataSource.dataSource.rowAtIndexPath(indexPath)
        let rowIdentifier = Identifiers.init(rawValue: row.identifier)!
        
        switch (rowIdentifier) {
        case .PersonCell:
            let person = row.anyData as! Person
            print("\(person) selected")
            
        case .ButtonCell:
            switch (row.anyData as! Button) {
            case .Add:
                print("add")
            case .Remove:
                print("remove")
            }
            
        default:
            print("\(row.identifier) selected")
        }
    }
    
    // need to fix section header and footer height if section is empty (only required for grouped table style)
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.heightForHeaderInSection(tableDataSource.sectionAtIndex(section))
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.heightForFooterInSection(tableDataSource.sectionAtIndex(section))
    }
}

//
//  ExampleTableViewController
//  Example
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

enum Button {
    case Add
    case Remove
}

class ExampleTableViewController: UITableViewController {
    var tableDataSource: TableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib("ButtonCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.dataSource = tableDataSource
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: Examples
    
    /// demonstrates various ways to setup the same simple data source
    func setupExample1() {
        let dataSource1 = DataSource(sections: [
            Section(rows: [
                Row(identifier: "TextCell", data: "a"),
                Row(identifier: "TextCell", data: "b"),
                Row(identifier: "TextCell", data: "c"),
                Row(identifier: "TextCell", data: "d"),
            ])
        ])
        
        let dataSource2 = DataSource(sections: [
            Section(rowIdentifier: "TextCell", rows: ["a", "b", "c", "d"])
        ])

        let dataSource3 = ["a", "b", "c", "d"]
            .dataSourceSection(rowIdentifier: "TextCell")
            .dataSource()
        
        let dataSource4 = ["a", "b", "c", "d"].dataSource(rowIdentifier: "TextCell")
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource1,
            configurator: TableViewCellConfigurator(identifier: "TextCell") { (title: String, cell: UITableViewCell, indexPath: IndexPath) in
                cell.textLabel?.text = "\(indexPath.row): \(title)"
            })
        
        debugPrint(dataSource1)
        debugPrint(dataSource2)
        debugPrint(dataSource3)
        debugPrint(dataSource4)
    }
    
    /// heterogenous data source with different row/cell types
    func setupExample2() {
        let dataSource = DataSource(sections: [
            Section(title: "B", footer: "Names starting with B", rowIdentifier: "PersonCell", rows: [
                Person(firstName: "Matthias", lastName: "Buchetics"),
            ]),
            Section<Person>(title: "M", footer: "Names starting with M", rowIdentifier: "PersonCell", rows: [
                Person(firstName: "Hugo", lastName: "Maier"),
                Person(firstName: "Max", lastName: "Mustermann"),
            ]),
            Section(title: "Strings", rowIdentifier: "TextCell", rows: [
                "some text",
                "another text"
            ]),
            Section(rowIdentifier: "ButtonCell", rows: [
                Button.Add,
                Button.Remove
            ]),
        ])
        
        debugPrint(dataSource)
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource,
            configurators: [
                TableViewCellConfigurator(identifier: "PersonCell") { (person: Person, cell: PersonCell, _) in
                    cell.firstNameLabel?.text = person.firstName
                    cell.lastNameLabel?.text = person.lastName
                },
                TableViewCellConfigurator(identifier: "TextCell") { (title: String, cell: UITableViewCell, _) in
                    cell.textLabel?.text = title
                },
                TableViewCellConfigurator(identifier: "ButtonCell") { (button: Button, cell: ButtonCell, _) in
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
        let dataSource1 = DataSource(sections: [
            Section(title: "B", rowIdentifier: "PersonCell", rows: [
                Person(firstName: "Matthias", lastName: "Buchetics"),
            ]),
            Section(title: "M", rowIdentifier: "PersonCell", rows: [
                Person(firstName: "Hugo", lastName: "Maier"),
                Person(firstName: "Max", lastName: "Mustermann"),
            ]),
        ])
        
        let dataSource2 = DataSource(section:
            Section(title: "Strings", rowIdentifier: "TextCell", rows: ["some text", "another text"]))
        
        var compoundDataSource = DataSource(dataSources: [dataSource1, dataSource2])
        
        compoundDataSource.append(dataSource: dataSource2)
        compoundDataSource.append(dataSource: dataSource1)
        compoundDataSource.removeSection(at: 1)
        
        debugPrint(compoundDataSource)
        
        tableDataSource = TableViewDataSource(
            dataSource: compoundDataSource,
            configurators: [
                TableViewCellConfigurator(identifier: "PersonCell") { (person: Person, cell: PersonCell, _) in
                    cell.firstNameLabel?.text = person.firstName
                    cell.lastNameLabel?.text = person.lastName
                },
                TableViewCellConfigurator(identifier: "TextCell") { (title: String, cell: UITableViewCell, _) in
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
        
        let dataSource = data.dataSource(rowIdentifier: "TextCell", orderedKeys: data.keys.sorted())
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource,
            configurator: TableViewCellConfigurator(identifier: "TextCell") { (title: String, cell: UITableViewCell, _) in
                cell.textLabel?.text = title
            })
    }
    
    /// example with an empty section
    func setupExample5() {
        let dataSource = DataSource(sections: [
            Section(title: "B", rowIdentifier: "PersonCell", rows: [
                Person(firstName: "Matthias", lastName: "Buchetics"),
            ]),
            Section(title: "M", rowIdentifier: "PersonCell", rows: [
                Person(firstName: "Hugo", lastName: "Maier"),
                Person(firstName: "Max", lastName: "Mustermann"),
            ]),
            Section(title: "Empty Section", rowIdentifier: "TextCell", rows: [String]()),
            Section(title: "Strings", rowIdentifier: "TextCell", rows: ["some text", "another text"]),
        ])
        
        debugPrint(dataSource)
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource,
            configurators: [
                TableViewCellConfigurator(identifier: "PersonCell") { (person: Person, cell: PersonCell, _) in
                    cell.firstNameLabel?.text = person.firstName
                    cell.lastNameLabel?.text = person.lastName
                },
                TableViewCellConfigurator(identifier: "TextCell") { (title: String, cell: UITableViewCell, _) in
                    cell.textLabel?.text = title
                },
            ])
    }
    
    /// example of an row creator closure
    func setupExample6() {
        let dataSource = DataSource(sections: [
            Section<String>(title: "test", rowCountClosure: { return 5 }, rowCreatorClosure: { (rowIndex) in
                if (rowIndex + 1) % 2 == 0 {
                    return Row(identifier: "TextCell", data: "even")
                } else {
                    return Row(identifier: "TextCell", data: "odd")
                }

            }),
            Section<Any>(title: "mixed", rowCountClosure: { return 5 }, rowCreatorClosure: { (rowIndex) in
                if rowIndex % 2 == 0 {
                    return Row(identifier: "TextCell", data: "test")
                } else {
                   return Row(identifier: "PersonCell", data: Person(firstName: "Max", lastName: "Mustermann"))
                }
            })
        ])
        
        debugPrint(dataSource)
        
        tableDataSource = TableViewDataSource(
            dataSource: dataSource,
            configurators: [
                TableViewCellConfigurator(identifier: "PersonCell") { (person: Person, cell: PersonCell, _) in
                    cell.firstNameLabel?.text = person.firstName
                    cell.lastNameLabel?.text = person.lastName
                },
                TableViewCellConfigurator(identifier: "TextCell") { (title: String, cell: UITableViewCell, _) in
                    cell.textLabel?.text = title
                },
            ])
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = tableDataSource.dataSource.row(at: indexPath)
        
        switch (row.identifier) {
        case "PersonCell":
            let person = row.anyData as! Person
            print("\(person) selected")
            
        case "ButtonCell":
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

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.heightForHeaderInSection(tableDataSource.section(at: section))
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.heightForFooterInSection(tableDataSource.section(at: section))
    }
}

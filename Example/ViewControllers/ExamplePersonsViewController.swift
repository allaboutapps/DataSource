//
//  ExamplePersonsViewController.swift
//  DataSource
//
//  Created by Matthias Buchetics on 27/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class ExamplePersonsViewController: UITableViewController {
    
    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = DataSource(
            sections: randomData(),
            cellDescriptors: [
                CellDescriptor<Person, PersonCell>()
                    .configure { (person, cell, indexPath) in
                        cell.configure(person: person)
                    }
                    .didSelect { (person, indexPath) in
                        print("selected: \(person)")
                        return .deselect
                }
            ]
        )
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    private func randomData() -> [Section] {
        let count = Int.random(5, 15)
        
        let persons = (0 ..< count).map { _ in
            Person(firstName: Randoms.randomFirstName(), lastName: Randoms.randomLastName())
        }.sorted()
        
        let letters = Set(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"])
        
        let firstGroup = persons.filter {
            $0.lastNameStartsWith(letters: letters)
        }
        
        let secondGroup = persons.filter {
            !$0.lastNameStartsWith(letters: letters)
        }
        
        return [
            Section(key: "firstGroup", rows: firstGroup.map(Row.init))
                .header { .title("A - L") },
            Section(key: "secondGroup", rows: secondGroup.map(Row.init))
                .header { .title("M - Z") },
        ]
    }
    
    @IBAction func refresh(_ sender: Any) {
        dataSource.set(sections: randomData())
        dataSource.updateAnimated(tableView: self.tableView)
    }
}

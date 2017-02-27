//
//  StartViewController
//  Example
//
//  Created by Matthias Buchetics on 26/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class StartViewController: UITableViewController {
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
                        self.dataSource.set(sections: self.randomData())
                        self.dataSource.updateAnimated(tableView: self.tableView)
                        
                        return .deselect
                    }
            ]
        )
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.fallbackDataSource = self
        dataSource.fallbackDelegate = self
    }
    
    private func randomData() -> [Section] {
        let count = Int.random(5, 15)
        
        let persons = (0 ..< count).map { _ in
            Person(firstName: Randoms.randomFirstName(), lastName: Randoms.randomLastName())
        }
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("fallback delegate didSelect")
    }
}

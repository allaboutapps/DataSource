//
//  StartViewController
//  Example
//
//  Created by Matthias Buchetics on 26/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

struct Example {
    let title: String
    let segue: String
}

class StartViewController: UITableViewController {
    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = DataSource(
            sections: [
                Section(key: "examples", rows: [
                    Row(Example(title: "Persons (sections, animated change)", segue: "showExamplePersons")),
                ])
            ],
            cellDescriptors: [
                CellDescriptor<Example, TextCell>()
                    .configure { (example, cell, indexPath) in
                        cell.textLabel?.text = example.title
                        cell.accessoryType = .disclosureIndicator
                    }
                    .didSelect { (example, indexPath) in
                        self.performSegue(withIdentifier: example.segue, sender: nil)
                        return .deselect
                    }
            ]
        )
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
}

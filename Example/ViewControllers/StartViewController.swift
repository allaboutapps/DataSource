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
    
    lazy var dataSource: DataSource = {
        DataSource([
            CellDescriptor<Example, TitleCell>()
                .configure { (example, cell, indexPath) in
                    cell.textLabel?.text = example.title
                    cell.accessoryType = .disclosureIndicator
                }
                .didSelect { (example, indexPath) in
                    self.performSegue(withIdentifier: example.segue, sender: nil)
                    return .deselect
                }
        ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.sections = [
            Section(key: "examples", models: [
                Example(title: "Random Persons", segue: "showRandomPersons"),
                Example(title: "Form", segue: "showForm"),
                Example(title: "On Demand", segue: "showOnDemand"),
            ])
        ]

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
}

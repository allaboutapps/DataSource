//
//  StartViewController
//  Example
//
//  Created by Matthias Buchetics on 26/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

// MARK: - View Controller

class StartViewController: UITableViewController {
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
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
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        var items = [
            Example(title: "Random Persons", segue: "showRandomPersons"),
            Example(title: "Form", segue: "showForm"),
            Example(title: "Lazy Rows", segue: "showLazyRows"),
            Example(title: "Diff & Update", segue: "showDiff"),
            Example(title: "Swipe To Delete", segue: "showSwipeToDelete"),
            Example(title: "Custom separators", segue: "showSeparatedSection"),
        ]
        
        if #available(iOS 11, *) {
            items.append(Example(title: "Swipe Actions", segue: "showSwipeExample"))
        }
        
        dataSource.sections = [
            Section(items: items)
        ]
        
        dataSource.reloadData(tableView, animated: false)
    }
}

// MARK: - Example

struct Example {
    
    let title: String
    let segue: String
}

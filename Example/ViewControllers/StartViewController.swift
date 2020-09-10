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
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        var items = [
            Example(title: "Random Persons", segue: "showRandomPersons"),
            Example(title: "Form", segue: "showForm"),
            Example(title: "Lazy Rows", segue: "showLazyRows"),
            Example(title: "Diff & Update", segue: "showDiff"),
            Example(title: "Swipe To Delete", segue: "showSwipeToDelete"),
            Example(title: "Custom separators", segue: "showSeparatedSection"),
            Example(title: "Expandable Cell", segue: "showExpandableCell"),
            Example(title: "Context Menu", segue: "showContextMenuExample")
        ]
        
        let separatorItems = [
            Example(title: "Random Persons", segue: "showRandomPersons"),
            Example(title: "Form", segue: "showForm"),
        ]
        
        if #available(iOS 11, *) {
            items.append(Example(title: "Swipe Actions", segue: "showSwipeExample"))
        }
        
        dataSource.sections = [
            Section(items: items),
            SeparatedSection(items: separatorItems, styleConfigureClosure: { transition -> SeparatorStyle? in
                let leftInset: CGFloat = transition.isLast ? 0 : 20
                return SeparatorStyle(edgeEnsets: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: -20),
                                      color: UIColor.blue,
                                      height: 1.0)
            })
        ]
        
        dataSource.reloadData(tableView, animated: false)
    }
}

// MARK: - Example

struct Example {
    
    let title: String
    let segue: String
}

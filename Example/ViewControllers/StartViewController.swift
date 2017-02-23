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
    
    var showMore = false
    var showExample4 = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = DataSource(
            sections: [
                Section(
                    key: "examples",
                    rows: [
                        Row("Example 1"),
                        Row("Example 2"),
                        Row("Example 3"),
                        Row("Example 4"),
                    ])
                    .header { .title("Examples") }
                    .footer { .title("Choose an example") },
                
                Section(
                    key: "more-examples",
                    rows: [
                        "Example a",
                        "Example b",
                        "Example c",
                    ].map { Row($0) })
                    .header { .title("More Examples") }
                    .isHidden { !self.showMore }
            ],
            cellDescriptors: [
                CellDescriptor<String, TextCell>()
                    .configure { (text, cell, _) in
                        cell.configure(text: text)
                    }
                    .isHidden { (text, indexPath) in
                        if text == "Example 4" {
                            return !self.showExample4
                        } else {
                            return false
                        }
                    }
                    .didSelect { (text, indexPath) in
                        print("selected \(text)")
                        
                        if indexPath == IndexPath(row: 2, section: 0) {
                            self.showExample4 = !self.showExample4
                        } else {
                            self.showMore = !self.showMore
                        }
                        
                        self.dataSource.updateVisibilityAnimated(tableView: self.tableView, sectionDeletionAnimation: .fade, sectionInsertionAnimation: .fade)
                        
                        return .deselect
                    }
            ]
        )
        
        dataSource.didSelect = { (row, indexPath) in
            print("fallback didSelect")
            return .deselect
        }
        
        // TODO: auto register nibs for cells
        tableView.registerNib(TextCell.self)
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.fallbackDataSource = self
        dataSource.fallbackDelegate = self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("fallback delegate didSelect")
    }
}

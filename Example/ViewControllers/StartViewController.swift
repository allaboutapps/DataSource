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
    let titles = [
        "Example 1",
        "Example 2",
        "Example 3",
        "Example 4",
        "Example 5",
        "Example 6"
    ]
    
    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = DataSource(
            sections: [
                Section(key: "titles", rows: titles.map { Row($0) })
                    .header { .title("Examples") }
                    .footer { .title("Choose an example") }
            ],
            cellDescriptors: [
                CellDescriptor<String, TextCell>()
                    .configure { (text, cell, indexPath) in
                        cell.configure(text: text)
                    }
                    .didSelect { (text, indexPath) in
                        print("selected \(text)")
                        return .deselect
                    }
            ]
        )
        
        dataSource.didSelect = { (row, indexPath) in
            print("fallback didSelect")
            return .deselect
        }
        
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

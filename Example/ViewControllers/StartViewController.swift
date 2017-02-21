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
    }
    
    /*
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let index = indexPath.row
        
        cell.textLabel?.text = titles[index]
        
        return cell
    }
 
    */
}

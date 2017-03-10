//
//  OnDemandViewController.swift
//  DataSource
//
//  Created by Matthias Buchetics on 08/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

// MARK: - View Controller

class OnDemandViewController: UITableViewController {
    
    lazy var dataSource: DataSource = {
        DataSource([
            CellDescriptor<String, TitleCell>()
                .configure { (title, cell, indexPath) in
                    let rowCount = self.dataSource.sections.first?.numberOfVisibleRows ?? 0
                    let fraction = Double(indexPath.row) / Double(rowCount)
                    
                    cell.textLabel?.text = title
                    cell.backgroundColor = UIColor.interpolate(from: UIColor.white, to: UIColor.red, fraction: fraction)
                }
                .didSelect { (person, indexPath) in
                    print("selected: \(person)")
                    return .deselect
            }
        ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.sections = [
            OnDemandSection(key: "on_demand", rowCount: { 100 }, rowClosure: { Row("\($0)") })
        ]
        
        tableView.estimatedRowHeight = 44.0
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
}

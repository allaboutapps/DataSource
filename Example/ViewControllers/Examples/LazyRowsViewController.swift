//
//  LazyRowsViewController.swift
//  DataSource
//
//  Created by Matthias Buchetics on 08/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

// MARK: - View Controller

class LazyRowsViewController: UITableViewController {
    
    let count = 1000
    var cachedRows = [Int: LazyRowType]()
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                CellDescriptor<String, TitleCell>()
                    .configure { (title, cell, indexPath) in
                        let fraction = Double(indexPath.row) / Double(self.count)
                        
                        cell.textLabel?.text = title
                        cell.backgroundColor = UIColor.interpolate(from: UIColor.white, to: UIColor.red, fraction: fraction)
                    }
                    .didSelect { (title, indexPath) in
                        print("selected: \(title)")
                        return .deselect
                }
            ],
            sectionDescriptors: [
                SectionDescriptor<String>()
                    .header { (title, _) in
                        let view = self.createSectionHeaderView(title: title)
                        return .view(view)
                    }
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.sectionHeaderHeight = 60.0
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.sections = [
            LazySection("Lazy Rows", count: { self.count }, row: { (index) in
                return self.cachedRow(at: index)
            })
        ]
        
        dataSource.reloadData(tableView, animated: false)
    }
    
    func cachedRow(at index: Int) -> LazyRowType {
        if let row = cachedRows[index] {
            print("cached row: \(index)")
            return row
        } else {
            print("create row: \(index)")
            let row = LazyRow<String>({
                return "\(index)"
            })
            cachedRows[index] = row
            return row
        }
    }
    
    func createSectionHeaderView(title: String) -> UIView {
        let label = UILabel()
        label.backgroundColor = UIColor.darkGray
        label.textAlignment = .center
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        return label
    }
}

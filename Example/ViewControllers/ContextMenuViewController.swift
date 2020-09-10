//
//  ContextMenuViewController.swift
//  Example
//
//  Created by Sandin Dulić on 09.09.20.
//  Copyright © 2020 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

@available(iOS 13.0, *)
class ContextMenuViewController: UITableViewController {
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                CellDescriptor<String, TitleCell>()
                    .configure { item, cell, _ in
                        cell.textLabel?.text = item
                    }
                    .configurationForMenuAtLocation { [weak self] _, indexPath -> UIContextMenuConfiguration in
                        guard let self = self else { return UIContextMenuConfiguration() }
                        let index = indexPath.row

                        let identifier = "\(index)" as NSString
                        return self.createContextMenuConfiguration(with: identifier)
                    }
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Context menu example"
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.sections = createSections()
        dataSource.reloadData(tableView, animated: false)
    }
    
    func createSections() -> [Section] {
        let items = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"]
        
        
        return [
            Section(items: items)
        ]
    }
    
    private func createContextMenuConfiguration(with identifier: NSString) -> UIContextMenuConfiguration {
        UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            let mapAction = UIAction(
                title: "Some title",
                image: UIImage(systemName: "map")) { _ in
            }

            let shareAction = UIAction(
                title: "Some title 2",
                image: UIImage(systemName: "square.and.arrow.up")) { _ in
            }

            return UIMenu(title: "", image: nil, children: [mapAction, shareAction])
        }
    }
}

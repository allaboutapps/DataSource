//
//  SwipeToDeleteViewController.swift
//  Example
//
//  Created by Matthias Buchetics on 08.05.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

// MARK: - View Controller

class SwipeToDeleteViewController: UITableViewController {
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                CellDescriptor<Item, TitleCell>()
                    .configure { (item, cell, indexPath) in
                        cell.textLabel?.text = item.title
                    }
                    .height { 80.0 }
                    .canEdit { true }
                    .editActions { (_, _) -> [UITableViewRowAction]? in
                        return [
                            UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (_, indexPath) in
                                self?.remove(at: indexPath)
                            }
                        ]
                    }
            ])
    }()
    
    var items: [Item] = (0..<30).map { Item(id: $0, title: "Item \($0)")}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.fallbackDelegate = self
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        reloadData(animated: false)
    }
    
    func reloadData(animated: Bool) {
        dataSource.sections = [
            Section(items: items)
        ]
        
        dataSource.reloadData(tableView, animated: animated)
    }
    
    func remove(at indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        reloadData(animated: true)
    }
    
    @IBAction func addItem(_ sender: Any) {
        let index: Int
        
        if let lastId = items.last?.id {
            index = lastId + 1
        } else {
            index = 0
        }
        
        let item = Item(id: index, title: "Item \(index)")
        items.append(item)
        
        reloadData(animated: true)
    }
}

struct Item: Equatable {
    let id: Int
    let title: String
}

extension Item: Diffable {
    
    public var diffIdentifier: String {
        return "\(id)"
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? Item else { return false }
        return self == other
    }
}

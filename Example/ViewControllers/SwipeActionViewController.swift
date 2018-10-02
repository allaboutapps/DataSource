//
//  SwipeActionViewController.swift
//  Example
//
//  Created by Oliver Krakora on 18.05.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

// MARK: - View Controller
@available(iOS 11,*)
class SwipeActionViewController: UITableViewController {
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                CellDescriptor<Item1, TitleCell>()
                    .configure { (item, cell, indexPath) in
                        cell.textLabel?.text = item.title
                        cell.backgroundColor = item.color
                    }
                    .height { 80.0 }
                    .canEdit { true }
                    .leadingSwipeAction { (_, _) -> UISwipeActionsConfiguration? in
                        return UISwipeActionsConfiguration(actions: [
                            UIContextualAction(style: .normal, title: "Vibrate", handler: { [weak self] (_, _, callback) in
                                self?.hapticFeedback.impactOccurred()
                                callback(true)
                            })
                        ])
                    }.trailingSwipeAction { [weak self] (_, indexPath) -> UISwipeActionsConfiguration? in
                        return UISwipeActionsConfiguration(actions: [
                            UIContextualAction(style: .normal, title: "Change Color", handler: { [weak self] (_, _, callback) in
                                callback(true)
                                self?.changeColor(for: indexPath)
                            })
                        ])
                    }
            ])
    }()
    
    var items: [Item1] = (0..<30).map { Item1(id: $0, title: "Item \($0)", color: .white)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func changeColor(for indexPath: IndexPath) {
        var item = items[indexPath.row]
        if item.color == .white {
            item.color = .orange
        } else {
            item.color = .white
        }
        items[indexPath.row] = item
        reloadData(animated: false)
    }
}

struct Item1: Equatable {
    let id: Int
    let title: String
    var color: UIColor
}

extension Item1: Diffable {
    
    public var diffIdentifier: String {
        return "\(id)"
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? Item1 else { return false }
        return self == other
    }
}

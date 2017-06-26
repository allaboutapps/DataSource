//
//  DiffViewController.swift
//  DataSource
//
//  Created by Matthias Buchetics on 17/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

// MARK: - View Controller

class DiffViewController: UITableViewController {
    
    var counter = 0
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                CellDescriptor<DiffItem, TitleCell>()
                    .configure { (item, cell, indexPath) in
                        cell.textLabel?.text = item.text
                    }
                    .update { (item, cell, indexPath) in
                        cell.textLabel?.update(text: item.text, animated: true)
                    }
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.sections = createSections()
        dataSource.reloadData(tableView, animated: false)
    }
    
    func createSections() -> [Section] {
        let english = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"]
        let german = ["Eins", "Zwei", "Drei", "Vier", "Fünf", "Sechs", "Sieben", "Acht", "Neun", "Zehn"]
        
        let values = counter % 2 == 0
            ? [1, 2, 3, 4, 6, 7]
            : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        let texts = counter % 2 == 0
            ? english
            : german
        
        return [
            Section(items: values.map {
                DiffItem($0, text: texts[$0 - 1])
            })
        ]
    }

    @IBAction func refresh(_ sender: Any) {
        counter += 1
        
        dataSource.sections = createSections()
        dataSource.reloadDataAnimated(tableView,
            rowDeletionAnimation: .automatic,
            rowInsertionAnimation: .automatic,
            rowReloadAnimation: .none)
    }
}

// MARK: - Diff Item

struct DiffItem {
    
    let value: Int
    let text: String
    let diffIdentifier: String
    
    init(_ value: Int, text: String) {
        self.value = value
        self.text = text
        self.diffIdentifier = String(value)
    }
}

extension DiffItem: Diffable {
    
    public func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? DiffItem else { return false }
        return self.text == other.text
    }
}

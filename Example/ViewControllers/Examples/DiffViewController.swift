//
//  DiffViewController.swift
//  DataSource
//
//  Created by Matthias Buchetics on 17/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import DataSource
import UIKit

// MARK: - View Controller

class DiffViewController: UITableViewController {
    var counter = 0
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                CellDescriptor<DiffItem, TitleCell>()
                    .configure { item, cell, _ in
                        cell.textLabel?.text = item.text
                    }
                    .update { item, cell, _ in
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

struct DiffItem: Hashable {
    let value: Int
    let text: String
    
    init(_ value: Int, text: String) {
        self.value = value
        self.text = text
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension DiffItem: Diffable {}

//
//  SeparatedSectionViewController.swift
//  Example
//
//  Created by Michael Heinzl on 12.09.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class SeparatedSectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
        tableView.separatorStyle = .none
        
        dataSource.sections = createSections()
        dataSource.reloadData(tableView, animated: false)
    }
    
    func createSections() -> [SectionType] {
        let english = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"]
        let german = ["Eins", "Zwei", "Drei", "Vier", "Fünf", "Sechs", "Sieben", "Acht", "Neun", "Zehn"]
        
        let values = counter % 2 == 0
            ? [1, 2, 3, 8, 9, 10]
            : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        let texts = counter % 2 == 0
            ? english
            : german
        
        return [
            SeparatedSection(items: values.map {
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

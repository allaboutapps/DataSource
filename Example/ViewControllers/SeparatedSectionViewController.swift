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
                },
                CellDescriptor<ColorItem, TitleCell>()
                    .configure { (item, cell, indexPath) in
                        cell.textLabel?.text = item.text
                },
                CellDescriptor<HeightItem, TitleCell>()
                    .configure { (item, cell, indexPath) in
                        cell.textLabel?.text = String(describing: item.height)
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
        
        // Default section
        let english = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"]
        let german = ["Eins", "Zwei", "Drei", "Vier", "Fünf", "Sechs", "Sieben", "Acht", "Neun", "Zehn"]
        
        let values = counter % 2 == 0
            ? [1, 2, 3, 8, 9, 10]
            : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        let texts = counter % 2 == 0
            ? english
            : german
        
        let defaultSection = SeparatedSection("Default section", items: values.map {
            DiffItem($0, text: texts[$0 - 1])
        })
        
        // Custom insets
        let insets = [16, 32, 48, 64].map { DiffItem($0, text: "\($0)") }
        
        let insetsSection = SeparatedSection("Custom insets", items: insets) { (transition) -> SeparatorStyle in
            if transition.isFirst {
                return SeparatorStyle(leftInset: 0.0)
            } else {
                let inset = (transition.from as? DiffItem)?.value ?? 0
                return SeparatorStyle(leftInset:  CGFloat(inset))
            }
        }
        
        // Custom colors
        let colors = [ColorItem(diffIdentifier: "color-1", color: .red, text: "red"),
                      ColorItem(diffIdentifier: "color-2", color: .green, text: "green"),
                      ColorItem(diffIdentifier: "color-3", color: .blue, text: "blue"),
                      ColorItem(diffIdentifier: "color-4", color: .purple, text: "purple")]
        
        let colorSection = SeparatedSection("Custom colors", items: colors) { (transition) -> SeparatorStyle in
            let color = (transition.from as? ColorItem)?.color ?? .black
            return SeparatorStyle(edgeEnsets: UIEdgeInsetsMake(0, 16, 0, 16), color: color)
        }
        
        // Custom view
        let customImageItems = [DiffItem(40, text: "-"),
                                DiffItem(41, text: "-"),
                                DiffItem(42, text: "-"),
                                DiffItem(43, text: "-"),
                                DiffItem(44, text: "-")]
        
        let customViewSection = SeparatedSection("Custom view", items: customImageItems) { (transition) -> UIView? in
            if transition.isFirst || transition.isLast {
                return nil
            } else {
                let imageView = UIImageView(image: #imageLiteral(resourceName: "wave"))
                imageView.contentMode = .scaleAspectFit
                return imageView
            }
        }
        
        // Custom height
        let customHeightItems = [2, 3, 5, 10].map { HeightItem(diffIdentifier: "height-\($0)", height: CGFloat($0)) }
        
        let heightSection = SeparatedSection("Custom height", items: customHeightItems) { (transition) -> SeparatorStyle in
            let height = (transition.from as? HeightItem)?.height ?? 1.0
            return SeparatorStyle(height: height)
        }
        
        return [
            defaultSection, insetsSection, colorSection, customViewSection, heightSection
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

struct HeightItem: Diffable {
    
    let diffIdentifier: String
    let height: CGFloat
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        return false
    }
    
}

struct ColorItem: Diffable {
    
    let diffIdentifier: String
    let color: UIColor
    let text: String
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        return false
    }
    
}

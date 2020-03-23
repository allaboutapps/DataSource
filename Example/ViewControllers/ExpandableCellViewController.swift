//
//  ExpandableCellViewController.swift
//  Example
//
//  Created by Matthias Buchetics on 23.03.20.
//  Copyright © 2020 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class ExpandableItem: Diffable {

    let id = UUID().uuidString
    let text: String
    var isExpanded: Bool = false
    
    init(text: String) {
        self.text = text
    }
    
    var diffIdentifier: String {
        return id
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        return false
    }
}

// MARK: - View Controller

class ExpandableCellViewController: UITableViewController {
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                CellDescriptor<ExpandableItem, TextCell>()
                    .configure { (item, cell, indexPath) in
                        cell.descriptionLabel?.text = item.text
                        cell.descriptionLabel.numberOfLines = item.isExpanded ? 0 : 3
                    }
                    .didSelect { [weak self] (item, _) -> SelectionResult in
                        self?.toggleItem(item)
                        return .deselect
                    }
                    .height { (item, _) -> CGFloat in
                        return UITableView.automaticDimension
                        //return item.isExpanded ? UITableView.automaticDimension : 80.0
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
    
    func toggleItem(_ item: ExpandableItem) {
        item.isExpanded.toggle()
        dataSource.reloadData(tableView, animated: true)
    }
    
    func createSections() -> [Section] {
        return [Section(items: items)]
    }
    
    var items = [
        ExpandableItem(text: "Morbi accumsan fermentum posuere vulputate iaculis ac nulla rutrum cum tempus massa vel, erat elit ipsum justo ligula enim luctus conubia est torquent. Inceptos fusce convallis ultricies platea nibh sapien montes per id, eleifend mattis quam dictum dignissim potenti fringilla semper, cubilia nostra eros faucibus neque tortor tempor posuere. Class neque lacinia vitae integer et mi libero ullamcorper fames tortor nullam nulla cursus, placerat orci tristique ipsum sagittis vulputate morbi euismod molestie volutpat cum. Amet condimentum vitae fames vivamus sapien sociis in ligula eget non lectus, pretium libero dis imperdiet hendrerit diam aenean urna sed."),
        ExpandableItem(text: "Ipsum ligula in ac sociis fringilla penatibus scelerisque mi himenaeos habitant commodo, phasellus fusce rutrum consectetur non duis sagittis elit platea. Ante molestie ac est tempus magna volutpat vulputate nisl tellus, posuere lorem potenti taciti facilisi venenatis lacinia sodales. Venenatis lacinia in purus commodo penatibus mollis, id feugiat ornare torquent nascetur lacus, nulla inceptos varius cras accumsan.")]
}

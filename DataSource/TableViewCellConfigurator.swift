//
//  TableViewCellConfigurator.swift
//  DataSource
//
//  Created by Matthias Buchetics on 26/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Protocols

public protocol TableViewCellConfiguratorType {
    var rowIdentifier: String { get }
    var cellIdentifier: String { get }
    
    func configureRow(row: RowType, cell: UITableViewCell, indexPath: NSIndexPath)
}

// MARK: - TableViewCellConfigurator

public class TableViewCellConfigurator<T, C: UITableViewCell>: TableViewCellConfiguratorType {
    /// Row identifier this configurator is responsible for
    public var rowIdentifier: String
    
    /// Cell identifier used to dequeue a table view cell
    public var cellIdentifier: String
    
    /// Typed configuration closure
    var configure: (T, C, NSIndexPath) -> Void
    
    /// Initializes the configurator given row and cell identifiers and a configure closure
    public init (rowIdentifier: String, cellIdentifier: String, configure: (data: T, cell: C, indexPath: NSIndexPath) -> Void) {
        self.cellIdentifier = cellIdentifier
        self.rowIdentifier = rowIdentifier
        self.configure = configure
    }
    
    /// Initializes the configurator using the same identifier for rowIdentifier and cellIdentifier and a configure closure
    public convenience init (_ cellIdentifier: String, configure: (data: T, cell: C, indexPath: NSIndexPath) -> Void) {
        self.init(rowIdentifier: cellIdentifier, cellIdentifier: cellIdentifier, configure: configure)
    }
    
    /// Takes a row and cell, makes the required casts and calls the configure closure
    public func configureRow(row: RowType, cell: UITableViewCell, indexPath: NSIndexPath) {
        if let data = row.anyData as? T, cell = cell as? C {
            configure(data, cell, indexPath)
        }
        else {
            assert(false, "invalid row or cell type");
        }
    }
}
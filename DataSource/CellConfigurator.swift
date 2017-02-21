//
//  CellConfigurator.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public enum SelectionResult {
    case deselect
    case keepSelected
}

public class CellConfigurator {
    
    let rowIdentifier: String
    let cellIdentifier: String
    
    var configure: (RowType, UITableViewCell, IndexPath) -> Void
    var didSelect: ((RowType, IndexPath) -> SelectionResult)?
    
    public init<Model, Cell: UITableViewCell>(
        rowIdentifier: String? = nil,
        cellIdentifier: String? = nil,
        configure: @escaping ((Model, Cell, IndexPath) -> Void)) {
        
        self.rowIdentifier = rowIdentifier ?? String(describing: Model.self)
        self.cellIdentifier = cellIdentifier ?? String(describing: Cell.self)
        
        self.configure = { (row, cell, indexPath) in
            guard let model = row.anyModel as? Model else {
                fatalError("[DataSource] configure: could not cast to expected model type \(Model.self)")
            }
            
            guard let cell = cell as? Cell else {
                fatalError("[DataSource] configure: could not cast to expected cell type \(Cell.self)")
            }
            
            configure(model, cell, indexPath)
        }
    }
    
    public func with<Model>(didSelect: ((Model, IndexPath) -> SelectionResult)? = nil) -> CellConfigurator {
        if let didSelect = didSelect {
            self.didSelect = { (row, indexPath) in
                guard let model = row.anyModel as? Model else {
                    fatalError("[DataSource] didSelect: could not cast to expected model type \(Model.self)")
                }
                
                return didSelect(model, indexPath)
            }
        } else {
            self.didSelect = nil
        }
        
        return self
    }
}

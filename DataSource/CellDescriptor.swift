//
//  CellDescriptor.swift
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

public protocol CellDescriptorType {
    
    var rowIdentifier: String { get }
    var cellIdentifier: String { get }
    
    var configureClosure: ((RowType, UITableViewCell, IndexPath) -> Void)? { get }
    var didSelectClosure: ((RowType, IndexPath) -> SelectionResult)? { get }
}

public class CellDescriptor<Model, Cell: UITableViewCell>: CellDescriptorType {
    
    public let rowIdentifier: String
    public let cellIdentifier: String
    
    public private(set) var configureClosure: ((RowType, UITableViewCell, IndexPath) -> Void)?
    public private(set) var didSelectClosure: ((RowType, IndexPath) -> SelectionResult)?
    
    public init(rowIdentifier: String? = nil, cellIdentifier: String? = nil) {
        self.rowIdentifier = rowIdentifier ?? String(describing: Model.self)
        self.cellIdentifier = cellIdentifier ?? String(describing: Cell.self)
    }
    
    public func configure(_ configure: @escaping (Model, Cell, IndexPath) -> Void) -> CellDescriptor {
        self.configureClosure = { (row, cell, indexPath) in
            guard let model = row.anyModel as? Model else {
                fatalError("[DataSource] configure: could not cast to expected model type \(Model.self)")
            }
            
            guard let cell = cell as? Cell else {
                fatalError("[DataSource] configure: could not cast to expected cell type \(Cell.self)")
            }
            
            configure(model, cell, indexPath)
        }
        
        return self
    }
    
    public func didSelect(_ closure: @escaping (Model, IndexPath) -> SelectionResult) -> CellDescriptor {
        self.didSelectClosure = { (row, indexPath) in
            guard let model = row.anyModel as? Model else {
                fatalError("[DataSource] didSelect: could not cast to expected model type \(Model.self)")
            }
            
            return closure(model, indexPath)
        }
        
        return self
    }
}

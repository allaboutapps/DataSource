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
    var cellClass: UITableViewCell.Type { get }
    
    var isHiddenClosure: ((RowType, IndexPath) -> Bool)? { get }
    var configureClosure: ((RowType, UITableViewCell, IndexPath) -> Void)? { get }
    var heightClosure: ((RowType, IndexPath) -> CGFloat)? { get }
    
    var willSelectClosure: ((RowType, IndexPath) -> IndexPath?)? { get }
    var willDeselectClosure: ((RowType, IndexPath) -> IndexPath?)? { get }
    var didSelectClosure: ((RowType, IndexPath) -> SelectionResult)? { get }
    var didDeselectClosure: ((RowType, IndexPath) -> Void)? { get }
}

public class CellDescriptor<Model, Cell: UITableViewCell>: CellDescriptorType {
    
    public let rowIdentifier: String
    public let cellIdentifier: String
    public let cellClass: UITableViewCell.Type
    
    public init(rowIdentifier: String? = nil, cellIdentifier: String? = nil) {
        self.rowIdentifier = rowIdentifier ?? String(describing: Model.self)
        self.cellIdentifier = cellIdentifier ?? String(describing: Cell.self)
        self.cellClass = Cell.self
    }
    
    // MARK: Typed Getters
    
    private func typedModel(_ row: RowType) -> Model {
        guard let model = row.anyModel as? Model else {
            fatalError("[DataSource] could not cast to expected model type \(Model.self)")
        }
        return model
    }
    
    private func typedCell(_ cell: UITableViewCell) -> Cell {
        guard let cell = cell as? Cell else {
            fatalError("[DataSource] could not cast to expected cell type \(Cell.self)")
        }
        return cell
    }
    
    // MARK: - Closures
    
    // MARK: isHidden
    
    public private(set) var isHiddenClosure: ((RowType, IndexPath) -> Bool)?
    
    public func isHidden(_ closure: @escaping (Model, IndexPath) -> Bool) -> CellDescriptor {
        isHiddenClosure = { (row, indexPath) in
            closure(self.typedModel(row), indexPath)
        }
        return self
    }
    
    // MARK: configure
    
    public private(set) var configureClosure: ((RowType, UITableViewCell, IndexPath) -> Void)?
    
    public func configure(_ closure: @escaping (Model, Cell, IndexPath) -> Void) -> CellDescriptor {
        configureClosure = { (row, cell, indexPath) in
            closure(self.typedModel(row), self.typedCell(cell), indexPath)
        }
        return self
    }
    
    // MARK: height
    
    public private(set) var heightClosure: ((RowType, IndexPath) -> CGFloat)?
    
    public func height(_ closure: @escaping (Model, IndexPath) -> CGFloat) -> CellDescriptor {
        heightClosure = { (row, indexPath) in
            return closure(self.typedModel(row), indexPath)
        }
        return self
    }
    
    // MARK: willSelect
    
    public private(set) var willSelectClosure: ((RowType, IndexPath) -> IndexPath?)?
    
    public func willSelect(_ closure: @escaping (Model, IndexPath) -> IndexPath?) -> CellDescriptor {
        willSelectClosure = { (row, indexPath) in
            return closure(self.typedModel(row), indexPath)
        }
        return self
    }
    
    // MARK: willSelect
    
    public private(set) var willDeselectClosure: ((RowType, IndexPath) -> IndexPath?)?
    
    public func willDeselect(_ closure: @escaping (Model, IndexPath) -> IndexPath?) -> CellDescriptor {
        willDeselectClosure = { (row, indexPath) in
            return closure(self.typedModel(row), indexPath)
        }
        return self
    }
    
    // MARK: didSelect
    
    public private(set) var didSelectClosure: ((RowType, IndexPath) -> SelectionResult)?
    
    public func didSelect(_ closure: @escaping (Model, IndexPath) -> SelectionResult) -> CellDescriptor {
        didSelectClosure = { (row, indexPath) in
            return closure(self.typedModel(row), indexPath)
        }
        return self
    }
    
    // MARK: didDeselect
    
    public private(set) var didDeselectClosure: ((RowType, IndexPath) -> Void)?
    
    public func didDeselect(_ closure: @escaping (Model, IndexPath) -> Void) -> CellDescriptor {
        didDeselectClosure = { (row, indexPath) in
            return closure(self.typedModel(row), indexPath)
        }
        return self
    }
}

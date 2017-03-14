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
    
    // UITableViewDataSource
    
    var configureClosure: ((RowType, UITableViewCell, IndexPath) -> Void)? { get }
    var canEditClosure: ((RowType, IndexPath) -> Bool)? { get }
    var canMoveClosure: ((RowType, IndexPath) -> Bool)? { get }
    var commitEditingClosure: ((RowType, UITableViewCellEditingStyle, IndexPath) -> Void)? { get }
    var moveRowClosure: ((RowType, (IndexPath, IndexPath)) -> Void)? { get }
    
    // UITableViewDelegate
    
    var heightClosure: ((RowType, IndexPath) -> CGFloat)? { get }
    var estimatedHeightClosure: ((RowType, IndexPath) -> CGFloat)? { get }
    
    var shouldHighlightClosure: ((RowType, IndexPath) -> Bool)? { get }
    var didHighlightClosure: ((RowType, IndexPath) -> Void)? { get }
    var didUnhighlightClosure: ((RowType, IndexPath) -> Void)? { get }
    
    var willSelectClosure: ((RowType, IndexPath) -> IndexPath?)? { get }
    var willDeselectClosure: ((RowType, IndexPath) -> IndexPath?)? { get }
    var didSelectClosure: ((RowType, IndexPath) -> SelectionResult)? { get }
    var didDeselectClosure: ((RowType, IndexPath) -> Void)? { get }
    
    var willDisplayClosure: ((RowType, UITableViewCell, IndexPath) -> Void)? { get }
    
    var editingStyleClosure: ((RowType, IndexPath) -> UITableViewCellEditingStyle)? { get }
    var titleForDeleteConfirmationButtonClosure: ((RowType, IndexPath) -> String?)? { get }
    var editActionsClosure: ((RowType, IndexPath) -> [UITableViewRowAction]?)? { get }
    var shouldIndentWhileEditingClosure: ((RowType, IndexPath) -> Bool)? { get }
    var willBeginEditingClosure: ((RowType, IndexPath) -> Void)? { get }
    var didEndEditingClosure: ((RowType, IndexPath) -> Void)? { get }
    
    var targetIndexPathForMoveClosure: ((RowType, (IndexPath, IndexPath)) -> IndexPath)? { get }
    var indentationLevelClosure: ((RowType, IndexPath) -> Int)? { get }
    var shouldShowMenuClosure: ((RowType, IndexPath) -> Bool)? { get }
    var canPerformActionClosure: ((RowType, Selector, Any?, IndexPath) -> Bool)? { get }
    var performActionClosure: ((RowType, Selector, Any?, IndexPath) -> Void)? { get }
    var canFocusClosure: ((RowType, IndexPath) -> Bool)? { get }
}

public class CellDescriptor<Item, Cell: UITableViewCell>: CellDescriptorType {
    
    public let rowIdentifier: String
    public let cellIdentifier: String
    public let cellClass: UITableViewCell.Type
    
    public init(rowIdentifier: String? = nil, cellIdentifier: String? = nil) {
        self.rowIdentifier = rowIdentifier ?? String(describing: Item.self)
        self.cellIdentifier = cellIdentifier ?? String(describing: Cell.self)
        self.cellClass = Cell.self
    }
    
    // MARK: Typed Getters
    
    private func typedItem(_ row: RowType) -> Item {
        guard let item = row.anyItem as? Item else {
            fatalError("[DataSource] could not cast to expected item type \(Item.self)")
        }
        return item
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
    
    public func isHidden(_ closure: @escaping (Item, IndexPath) -> Bool) -> CellDescriptor {
        isHiddenClosure = { (row, indexPath) in
            closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: - UITableViewDataSource
    
    // MARK: configure
    
    public private(set) var configureClosure: ((RowType, UITableViewCell, IndexPath) -> Void)?
    
    public func configure(_ closure: @escaping (Item, Cell, IndexPath) -> Void) -> CellDescriptor {
        configureClosure = { (row, cell, indexPath) in
            closure(self.typedItem(row), self.typedCell(cell), indexPath)
        }
        return self
    }
    
    // MARK: canEdit
    
    public private(set) var canEditClosure: ((RowType, IndexPath) -> Bool)?
    
    public func canEdit(_ closure: @escaping (Item, IndexPath) -> Bool) -> CellDescriptor {
        canEditClosure = { (row, indexPath) in
            closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: canMove
    
    public private(set) var canMoveClosure: ((RowType, IndexPath) -> Bool)?
    
    public func canMove(_ closure: @escaping (Item, IndexPath) -> Bool) -> CellDescriptor {
        canMoveClosure = { (row, indexPath) in
            closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: height
    
    public private(set) var heightClosure: ((RowType, IndexPath) -> CGFloat)?
    
    public func height(_ closure: @escaping (Item, IndexPath) -> CGFloat) -> CellDescriptor {
        heightClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: estimatedHeight
    
    public private(set) var estimatedHeightClosure: ((RowType, IndexPath) -> CGFloat)?
    
    public func estimatedHeight(_ closure: @escaping (Item, IndexPath) -> CGFloat) -> CellDescriptor {
        estimatedHeightClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: commitEditingStyle
    
    public private(set) var commitEditingClosure: ((RowType, UITableViewCellEditingStyle, IndexPath) -> Void)?
    
    public func commitEditing(_ closure: @escaping (Item, UITableViewCellEditingStyle, IndexPath) -> Void?) -> CellDescriptor {
        commitEditingClosure = { (row, editingStyle, indexPath) in
            return closure(self.typedItem(row), editingStyle, indexPath)
        }
        return self
    }
    
    // MARK: moveRow
    
    public private(set) var moveRowClosure: ((RowType, (IndexPath, IndexPath)) -> Void)?
    
    public func moveRow(_ closure: @escaping (Item, (IndexPath, IndexPath)) -> Void?) -> CellDescriptor {
        moveRowClosure = { (row, indexPaths) in
            return closure(self.typedItem(row), indexPaths)
        }
        return self
    }
    
    // MARK: - UITableViewDelegate
    
    // MARK: shouldHighlight
    
    public private(set) var shouldHighlightClosure: ((RowType, IndexPath) -> Bool)?
    
    public func shouldHighlight(_ closure: @escaping (Item, IndexPath) -> Bool) -> CellDescriptor {
        shouldHighlightClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: didHighlight
    
    public private(set) var didHighlightClosure: ((RowType, IndexPath) -> Void)?
    
    public func didHighlight(_ closure: @escaping (Item, IndexPath) -> Void) -> CellDescriptor {
        didHighlightClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: didUnhighlight
    
    public private(set) var didUnhighlightClosure: ((RowType, IndexPath) -> Void)?
    
    public func didUnhighlight(_ closure: @escaping (Item, IndexPath) -> Void) -> CellDescriptor {
        didUnhighlightClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: willSelect
    
    public private(set) var willSelectClosure: ((RowType, IndexPath) -> IndexPath?)?
    
    public func willSelect(_ closure: @escaping (Item, IndexPath) -> IndexPath?) -> CellDescriptor {
        willSelectClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: willSelect
    
    public private(set) var willDeselectClosure: ((RowType, IndexPath) -> IndexPath?)?
    
    public func willDeselect(_ closure: @escaping (Item, IndexPath) -> IndexPath?) -> CellDescriptor {
        willDeselectClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: didSelect
    
    public private(set) var didSelectClosure: ((RowType, IndexPath) -> SelectionResult)?
    
    public func didSelect(_ closure: @escaping (Item, IndexPath) -> SelectionResult) -> CellDescriptor {
        didSelectClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: didDeselect
    
    public private(set) var didDeselectClosure: ((RowType, IndexPath) -> Void)?
    
    public func didDeselect(_ closure: @escaping (Item, IndexPath) -> Void) -> CellDescriptor {
        didDeselectClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: willDisplay
    
    public private(set) var willDisplayClosure: ((RowType, UITableViewCell, IndexPath) -> Void)?
    
    public func willDisplay(_ closure: @escaping (Item, Cell, IndexPath) -> Void) -> CellDescriptor {
        willDisplayClosure = { (row, cell, indexPath) in
            return closure(self.typedItem(row), self.typedCell(cell), indexPath)
        }
        return self
    }
    
    // MARK: didEndDisplaying
    
    public private(set) var didEndDisplayingClosure: ((UITableViewCell, IndexPath) -> Void)?
    
    public func didEndDisplaying(_ closure: @escaping (Cell, IndexPath) -> Void) -> CellDescriptor {
        didEndDisplayingClosure = { (cell, indexPath) in
            return closure(self.typedCell(cell), indexPath)
        }
        return self
    }
    
    // MARK: editingStyle
    
    public private(set) var editingStyleClosure: ((RowType, IndexPath) -> UITableViewCellEditingStyle)?
    
    public func editingStyle(_ closure: @escaping (Item, IndexPath) -> UITableViewCellEditingStyle) -> CellDescriptor {
        editingStyleClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: titleForDeleteConfirmationButton
    
    public private(set) var titleForDeleteConfirmationButtonClosure: ((RowType, IndexPath) -> String?)?
    
    public func titleForDeleteConfirmationButton(_ closure: @escaping (Item, IndexPath) -> String?) -> CellDescriptor {
        titleForDeleteConfirmationButtonClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: editActions
    
    public private(set) var editActionsClosure: ((RowType, IndexPath) -> [UITableViewRowAction]?)?
    
    public func editActions(_ closure: @escaping (Item, IndexPath) -> [UITableViewRowAction]?) -> CellDescriptor {
        editActionsClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: shouldIndentWhileEditing
    
    public private(set) var shouldIndentWhileEditingClosure: ((RowType, IndexPath) -> Bool)?
    
    public func shouldIndentWhileEditing(_ closure: @escaping (Item, IndexPath) -> Bool) -> CellDescriptor {
        shouldIndentWhileEditingClosure = { (row, indexPath) in
            return closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: willBeginEditing
    
    public private(set) var willBeginEditingClosure: ((RowType, IndexPath) -> Void)?
    
    public func willBeginEditing(_ closure: @escaping (Item, IndexPath) -> Void) -> CellDescriptor {
        willBeginEditingClosure = { (row, indexPath) in
            closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: didEndEditing
    
    public private(set) var didEndEditingClosure: ((RowType, IndexPath) -> Void)?

    public func didEndEditing(_ closure: @escaping (Item, IndexPath) -> Void) -> CellDescriptor {
        didEndEditingClosure = { (row, indexPath) in
            closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: targetIndexPathForMove
    
    public private(set) var targetIndexPathForMoveClosure: ((RowType, (IndexPath, IndexPath)) -> IndexPath)?
    
    public func targetIndexPathForMove(_ closure: @escaping (Item, (IndexPath, IndexPath)) -> IndexPath) -> CellDescriptor {
        targetIndexPathForMoveClosure = { (row, indexPaths) in
            closure(self.typedItem(row), indexPaths)
        }
        return self
    }
    
    // MARK: indentationLevel
    
    public private(set) var indentationLevelClosure: ((RowType, IndexPath) -> Int)?
    
    public func indentationLevel(_ closure: @escaping (Item, IndexPath) -> Int) -> CellDescriptor {
        indentationLevelClosure = { (row, indexPath) in
            closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: shouldShowMenu
    
    public private(set) var shouldShowMenuClosure: ((RowType, IndexPath) -> Bool)?
    
    public func shouldShowMenu(_ closure: @escaping (Item, IndexPath) -> Bool) -> CellDescriptor {
        shouldShowMenuClosure = { (row, indexPath) in
            closure(self.typedItem(row), indexPath)
        }
        return self
    }
    
    // MARK: canPerformAction
    
    public private(set) var canPerformActionClosure: ((RowType, Selector, Any?, IndexPath) -> Bool)?
    
    public func canPerformAction(_ closure: @escaping (Item, Selector, Any?, IndexPath) -> Bool) -> CellDescriptor {
        canPerformActionClosure = { (row, selector, sender, indexPath) in
            closure(self.typedItem(row), selector, sender, indexPath)
        }
        return self
    }
    
    // MARK: performAction
    
    public private(set) var performActionClosure: ((RowType, Selector, Any?, IndexPath) -> Void)?
    
    public func performAction(_ closure: @escaping (Item, Selector, Any?, IndexPath) -> Void) -> CellDescriptor {
        performActionClosure = { (row, selector, sender, indexPath) in
            closure(self.typedItem(row), selector, sender, indexPath)
        }
        return self
    }
    
    // MARK: canFocus
    
    public private(set) var canFocusClosure: ((RowType, IndexPath) -> Bool)?
    
    public func canFocus(_ closure: @escaping (Item, IndexPath) -> Bool) -> CellDescriptor {
        canFocusClosure = { (row, indexPath) in
            closure(self.typedItem(row), indexPath)
        }
        return self
    }
}

//
//  DataSource.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Diff

public class DataSource: NSObject {
    
    public var sections: [SectionType] = []
    public internal(set) var visibleSections: [SectionType] = []
    
    // MARK: UITableViewDataSource
    
    public var configure: ((RowType, UITableViewCell, IndexPath) -> Void)? = nil
    public var canEdit: ((RowType, IndexPath) -> Bool)? = nil
    public var canMove: ((RowType, IndexPath) -> Bool)? = nil
    public var sectionIndexTitles: (() -> [String]?)? = nil
    public var sectionForSectionIndex: ((String, Int) -> Int)? = nil
    public var commitEditing: ((RowType, UITableViewCellEditingStyle, IndexPath) -> Void)? = nil
    public var moveRow: ((RowType, (IndexPath, IndexPath)) -> Void)? = nil
    
    public var fallbackDataSource: UITableViewDataSource? = nil
    
    // MARK: UITableViewDelegate
    
    public var height: ((RowType, IndexPath) -> CGFloat)? = nil
    
    // no RowType parameter for estimatedHeight because we do not want to potentially instantiate
    // a LazyRow just to get the height estimate
    public var estimatedHeight: ((IndexPath) -> CGFloat)? = nil
    
    public var shouldHighlight: ((RowType, IndexPath) -> Bool)? = nil
    public var didHighlight: ((RowType, IndexPath) -> Void)? = nil
    public var didUnhighlight: ((RowType, IndexPath) -> Void)? = nil
    
    public var willSelect: ((RowType, IndexPath) -> IndexPath?)? = nil
    public var willDeselect: ((RowType, IndexPath) -> IndexPath?)? = nil
    public var didSelect: ((RowType, IndexPath) -> SelectionResult)? = nil
    public var didDeselect: ((RowType, IndexPath) -> Void)? = nil
    
    public var willDisplay: ((RowType, UITableViewCell, IndexPath) -> Void)? = nil
    public var didEndDisplaying: ((UITableViewCell, IndexPath) -> Void)? = nil
    
    public var editingStyle: ((RowType, IndexPath) -> UITableViewCellEditingStyle)? = nil
    public var titleForDeleteConfirmationButton: ((RowType, IndexPath) -> String?)? = nil
    public var editActions: ((RowType, IndexPath) -> [UITableViewRowAction]?)? = nil
    public var shouldIndentWhileEditing: ((RowType, IndexPath) -> Bool)? = nil
    public var willBeginEditing: ((RowType, IndexPath) -> Void)? = nil
    public var didEndEditing: ((IndexPath?) -> Void)? = nil
    
    public var sectionHeader: ((SectionType, Int) -> HeaderFooter)? = nil
    public var sectionFooter: ((SectionType, Int) -> HeaderFooter)? = nil
    
    public var sectionHeaderHeight: ((SectionType, Int) -> SectionHeight)? = nil
    public var sectionFooterHeight: ((SectionType, Int) -> SectionHeight)? = nil
    
    public var willDisplaySectionHeader: ((SectionType, UIView, Int) -> Void)? = nil
    public var willDisplaySectionFooter: ((SectionType, UIView, Int) -> Void)? = nil
    
    public var didEndDisplayingSectionHeader: ((UIView, Int) -> Void)? = nil
    public var didEndDisplayingSectionFooter: ((UIView, Int) -> Void)? = nil
    
    public var targetIndexPathForMove: ((RowType, (IndexPath, IndexPath)) -> IndexPath)? = nil
    public var indentationLevel: ((RowType, IndexPath) -> Int)? = nil
    public var shouldShowMenu: ((RowType, IndexPath) -> Bool)? = nil
    public var canPerformAction: ((RowType, Selector, Any?, IndexPath) -> Bool)? = nil
    public var performAction: ((RowType, Selector, Any?, IndexPath) -> Void)? = nil
    public var canFocus: ((RowType, IndexPath) -> Bool)? = nil
    
    // MARK: UITableViewDataSourcePrefetching
    
    public var prefetchRows: (([IndexPath]) -> Void)? = nil
    public var cancelPrefetching: (([IndexPath]) -> Void)? = nil
    
    public weak var fallbackDataSourcePrefetching: UITableViewDataSourcePrefetching? = nil
    
    // MARK: Fallback delegate
    
    /// Fallback used when DataSource doesn't handle delegate method itself.
    /// - Note: The fallback delegate needs to be set *before* setting the table view's delegate, otherwise certain delegate methods will never be called.
    public weak var fallbackDelegate: UITableViewDelegate? = nil
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return fallbackDelegate
    }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        } else {
            return fallbackDelegate?.responds(to: aSelector) ?? false
        }
    }
    
    // MARK: Additional
    
    public var isRowHidden: ((RowType, IndexPath) -> Bool)? = nil
    public var isSectionHidden: ((SectionType, Int) -> Bool)? = nil
    public var update: ((RowType, UITableViewCell, IndexPath) -> Void)? = nil
    
    // MARK: Internal
    
    var cellDescriptors: [String: CellDescriptorType] = [:]
    var sectionDescriptors: [String: SectionDescriptorType] = [:]
    
    var reuseIdentifiers: Set<String> = []
    let registerNibs: Bool
    
    // MARK: Init
    
    public init(cellDescriptors: [CellDescriptorType], sectionDescriptors: [SectionDescriptorType] = [], registerNibs: Bool = true) {
        self.registerNibs = registerNibs
        
        for d in cellDescriptors {
            self.cellDescriptors[d.rowIdentifier] = d
        }
        
        let defaultSectionDescriptors: [SectionDescriptorType] = [
            SectionDescriptor<Void>(),
            SectionDescriptor<String>()
                .header { (title, _) in
                    .title(title)
            }
        ]
        
        for d in defaultSectionDescriptors {
            self.sectionDescriptors[d.identifier] = d
        }
        
        for d in sectionDescriptors {
            self.sectionDescriptors[d.identifier] = d
        }
        
        super.init()
    }
    
    // MARK: Getters & Setters
    
    public func section(at index: Int) -> SectionType {
        return sections[index]
    }
    
    public func row(at indexPath: IndexPath) -> RowType {
        return sections[indexPath.section].row(at: indexPath.row)
    }
    
    public func visibleSection(at index: Int) -> SectionType {
        return visibleSections[index]
    }
    
    public func visibleRow(at indexPath: IndexPath) -> RowType {
        return visibleSections[indexPath.section].visibleRow(at: indexPath.row)
    }
    
    // MARK: Cell Descriptors
    
    public func cellDescriptor(at indexPath: IndexPath) -> CellDescriptorType {
        let row = visibleRow(at: indexPath)
        
        if let cellDescriptor = cellDescriptors[row.identifier] {
            return cellDescriptor
        } else {
            fatalError("[DataSource] no cellDescriptor found for indexPath \(indexPath) with identifier \(row.identifier)")
        }
    }
    
    public func cellDescriptor(for rowIdentifier: String) -> CellDescriptorType {
        if let cellDescriptor = cellDescriptors[rowIdentifier] {
            return cellDescriptor
        } else {
            fatalError("[DataSource] no cellDescriptor found for rowIdentifier \(rowIdentifier)")
        }
    }
    
    // MARK: Section Descriptors
    
    public func sectionDescriptor(at index: Int) -> SectionDescriptorType? {
        let section = visibleSection(at: index)
        
        if let sectionDescriptor = sectionDescriptors[section.identifier] {
            return sectionDescriptor
        } else {
            print("[DataSource] no sectionDescriptor found for section \(index)")
            return nil
        }
    }
    
    public func sectionDescriptor(for identifier: String) -> SectionDescriptorType? {
        if let sectionDescriptor = sectionDescriptors[identifier] {
            return sectionDescriptor
        } else {
            print("[DataSource] no sectionDescriptor found for sectionIdentifier \(identifier)")
            return nil
        }
    }

    // MARK: Visibility
    
    internal func updateVisibility() {
        visibleSections = updateSectionVisiblity()
    }
    
    internal func updateSectionVisiblity() -> [SectionType] {
        var visibleSections = [SectionType]()
        
        for (index, section) in sections.enumerated() {
            section.updateVisibility(sectionIndex: index, dataSource: self)
            
            let sectionDescriptor = self.sectionDescriptor(for: section.identifier)
            let isHidden: Bool
            
            if let closure = sectionDescriptor?.isHiddenClosure ?? isSectionHidden {
                isHidden = closure(section, index)
            } else {
                isHidden = false
            }
            
            if isHidden == false && section.numberOfVisibleRows > 0 {
                visibleSections.append(section)
            }
        }
        
        return visibleSections
    }
    
    // MARK: Reload Data
    
    public func reloadData(_ tableView: UITableView, animated: Bool) {
        if tableView.dataSource == nil {
            tableView.dataSource = self
        }
        
        if tableView.delegate == nil {
            tableView.delegate = self
        }
        
        if animated {
            reloadDataAnimated(tableView)
        } else {
            visibleSections = updateSectionVisiblity()
            tableView.reloadData()
        }
    }
    
    public func reloadDataAnimated(
        _ tableView: UITableView,
        rowDeletionAnimation: UITableViewRowAnimation = .fade,
        rowInsertionAnimation: UITableViewRowAnimation = .fade,
        rowReloadAnimation: UITableViewRowAnimation = .none,
        sectionDeletionAnimation: UITableViewRowAnimation = .fade,
        sectionInsertionAnimation: UITableViewRowAnimation = .fade
        ) {
        
        let oldSections = visibleSections.map { $0.diffableSection }
        let newSections = updateSectionVisiblity()
        let diffableNewSections = newSections.map { $0.diffableSection }
        
        let diff = computeDiff(oldSections: oldSections, newSections: diffableNewSections)
        let updates = computeUpdate(oldSections: oldSections, newSections: diffableNewSections)
        
        self.visibleSections = newSections
        
        if rowReloadAnimation == .none {
            for update in updates {
                updateRow(tableView, row: update.to.row, at: update.from.indexPath)
            }
        }
        
        tableView.apply(
            batch: Batch(diff: diff, updates: updates),
            rowDeletionAnimation: rowDeletionAnimation,
            rowInsertionAnimation: rowInsertionAnimation,
            rowReloadAnimation: rowReloadAnimation,
            sectionDeletionAnimation: sectionDeletionAnimation,
            sectionInsertionAnimation: sectionInsertionAnimation)
    }
    
    public func updateRow(_ tableView: UITableView, row: RowType, at indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(for: row.identifier)
        
        let closure =
            cellDescriptor.updateClosure
            ?? update
            ?? cellDescriptor.configureClosure
            ?? configure
        
        if let cell = tableView.cellForRow(at: indexPath), let closure = closure {
            closure(row, cell, indexPath)
        }
    }
}

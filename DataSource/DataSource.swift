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
    
    public struct Item {
        let indexPath: IndexPath
        let row: RowType
    }
    
    public private(set) var allSections: [Section] = []
    public private(set) var visibleSections: [Section] = []

    public var isRowHidden: ((RowType, IndexPath) -> Bool)? = nil
    public var isSectionHidden: ((Section, Int) -> Bool)? = nil
    
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
    public var shouldHighlight: ((RowType, IndexPath) -> Bool)? = nil
    public var didHighlight: ((RowType, IndexPath) -> Void)? = nil
    public var didUnhighlight: ((RowType, IndexPath) -> Void)? = nil
    public var willSelect: ((RowType, IndexPath) -> IndexPath?)? = nil
    public var willDeselect: ((RowType, IndexPath) -> IndexPath?)? = nil
    public var didSelect: ((RowType, IndexPath) -> SelectionResult)? = nil
    public var didDeselect: ((RowType, IndexPath) -> Void)? = nil
    
    public var fallbackDelegate: UITableViewDelegate? = nil
    
    // MARK: UITableViewDataSourcePrefetching
    
    public var prefetchRows: (([IndexPath]) -> Void)? = nil
    public var cancelPrefetching: (([IndexPath]) -> Void)? = nil
    
    public var fallbackDataSourcePrefetching: UITableViewDataSourcePrefetching? = nil
    
    // MARK: Internal
    
    var cellDescriptors: [String: CellDescriptorType] = [:]
    var reuseIdentifiers: Set<String> = []
    let registerNibs: Bool
    
    // MARK: Init
    
    public init(_ cellDescriptors: [CellDescriptorType], registerNibs: Bool = true) {
        self.registerNibs = registerNibs
        
        for d in cellDescriptors {
            self.cellDescriptors[d.rowIdentifier] = d
        }
        
        super.init()
    }
    
    // MARK: Getters & Setters
    
    public var sections: [Section] {
        get {
            return allSections
        }
        set {
            allSections = newValue
            updateVisibility()
        }
    }
    
    public func row(at indexPath: IndexPath) -> RowType {
        return allSections[indexPath.section].rows[indexPath.row]
    }
    
    public func visibleRow(at indexPath: IndexPath) -> RowType {
        return visibleSections[indexPath.section].visibleRows[indexPath.row]
    }
    
    public var flattenedVisibleRows: [Item] {
        return visibleSections.enumerated().flatMap { (section) -> [Item] in
            section.element.visibleRows.enumerated().map { (row) in
                Item(indexPath: IndexPath(row: row.offset, section: section.offset), row: row.element as RowType)
            }
        }
    }
    
    // MARK: Cell Descriptors
    
    public func cellDescriptor(at indexPath: IndexPath) -> CellDescriptorType {
        let row = visibleSections[indexPath.section][indexPath.row]
        
        if let cellDescriptor = cellDescriptors[row.identifier] {
            return cellDescriptor
        } else {
            fatalError("[DataSource] no cellDescriptor found for indexPath \(indexPath)")
        }
    }
    
    public func cellDescriptor(for rowIdentifier: String) -> CellDescriptorType {
        if let cellDescriptor = cellDescriptors[rowIdentifier] {
            return cellDescriptor
        } else {
            fatalError("[DataSource] no cellDescriptor found for rowIdentifier \(rowIdentifier)")
        }
    }
    
    // MARK: Updates
    
    public func replace(key: String? = nil, section: Section) {
        if let index = sections.index(where: { $0.key == key ?? section.key }) {
            self.sections[index] = section
        }
    }
    
    // MARK: Visibility
    
    public func updateAnimated(sections: [Section]? = nil, tableView: UITableView, rowDeletionAnimation: UITableViewRowAnimation = .fade, rowInsertionAnimation: UITableViewRowAnimation = .fade, sectionDeletionAnimation: UITableViewRowAnimation = .fade, sectionInsertionAnimation: UITableViewRowAnimation = .fade) {
        
        if let sections = sections {
            self.allSections = sections
        }
        
        let oldSections = visibleSections.map { $0.diffClone }
        let newSections = getVisibleSections()
        let diff = self.diff(oldSections: oldSections, newSections: newSections)
        
        self.visibleSections = newSections
        
        tableView.apply(diff, rowDeletionAnimation: rowDeletionAnimation, rowInsertionAnimation: rowInsertionAnimation, sectionDeletionAnimation: sectionDeletionAnimation, sectionInsertionAnimation: sectionInsertionAnimation)
    }
    
    public func update(sections: [Section]? = nil, tableView: UITableView) {
        if let sections = sections {
            self.allSections = sections
        }
        
        let newVisibleSections = getVisibleSections()
        
        self.visibleSections = newVisibleSections
        tableView.reloadData()
    }
    
    private func updateVisibility() {
        self.visibleSections = getVisibleSections()
    }
    
    private func getVisibleSections() -> [Section] {
        var visibleSections = [Section]()
        
        for (sectionIndex, section) in allSections.enumerated() {
            var visibleRows = [RowType]()
            
            for (rowIndex, row) in section.rows.enumerated() {
                let cellDescriptor = cellDescriptors[row.identifier]
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                let isHidden = cellDescriptor?.isHiddenClosure?(row, indexPath) ?? isRowHidden?(row, indexPath) ?? false
                
                if !isHidden {
                    visibleRows.append(row)
                }
            }
            
            section.update(visibleRows: visibleRows)
            
            let isHidden = section.isHiddenClosure?(section, sectionIndex) ?? isSectionHidden?(section, sectionIndex) ?? false
            
            if !isHidden && visibleRows.count > 0 {
                visibleSections.append(section)
            }
        }
        
        return visibleSections
    }
    
    // MARK: Diff
    
    public func diff(oldSections: [Section], newSections: [Section]) -> NestedExtendedDiff {
        let diff = oldSections.nestedExtendedDiff(
            to: newSections,
            isEqualSection: { (section1, section2) -> Bool in
                section1.key == section2.key
            },
            isEqualElement: { (row1, row2) -> Bool in
                guard
                    let a = row1.anyModel as? DataSourceDiffable,
                    let b = row2.anyModel as? DataSourceDiffable
                else {
                    return false
                }
                
                return a.isEqualToDiffable(b)
            })
        
        return diff
    }
}

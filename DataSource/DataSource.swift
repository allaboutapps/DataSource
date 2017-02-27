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
    
    public private(set) var sections: [Section] = []
    public private(set) var visibleSections: [Section] = []
    
    private var cellDescriptors: [String: CellDescriptorType] = [:]
    
    var reuseIdentifiers: Set<String> = []
    let registerNibs: Bool
    
    // MARK: Fallback UITableViewDataSource
    
    public var configure: ((RowType, UITableViewCell, IndexPath) -> Void)? = nil
    
    public var fallbackDataSource: UITableViewDataSource? = nil
    
    // MARK: Fallback UITableViewDelegate
    
    public var height: ((RowType, IndexPath) -> CGFloat)? = nil
    public var didSelect: ((RowType, IndexPath) -> SelectionResult)? = nil
    
    public var fallbackDelegate: UITableViewDelegate? = nil
    
    // MARK: Init
    
    public init(sections: [Section], cellDescriptors: [CellDescriptorType], registerNibs: Bool = true) {
        self.registerNibs = registerNibs
        self.sections = sections
        
        for d in cellDescriptors {
            self.cellDescriptors[d.rowIdentifier] = d
        }
        
        super.init()
        
        updateVisibility()
    }
    
    // MARK: Getters
    
    public func row(at indexPath: IndexPath) -> RowType {
        return sections[indexPath.section].rows[indexPath.row]
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
    
    public func set(sections: [Section]) {
        self.sections = sections
    }
    
    public func replace(key: String? = nil, section: Section) {
        if let index = sections.index(where: { $0.key == key ?? section.key }) {
            self.sections[index] = section
        }
    }
    
    // MARK: Visibility
    
    public func updateAnimated(tableView: UITableView, rowDeletionAnimation: UITableViewRowAnimation = .fade, rowInsertionAnimation: UITableViewRowAnimation = .fade, sectionDeletionAnimation: UITableViewRowAnimation = .fade, sectionInsertionAnimation: UITableViewRowAnimation = .fade) {
        
        let oldSections = visibleSections.map { $0.diffClone }
        let newSections = getVisibleSections()
        let diff = self.diff(oldSections: oldSections, newSections: newSections)
        
        self.visibleSections = newSections
        
        tableView.apply(diff, rowDeletionAnimation: rowDeletionAnimation, rowInsertionAnimation: rowInsertionAnimation, sectionDeletionAnimation: sectionDeletionAnimation, sectionInsertionAnimation: sectionInsertionAnimation)
    }
    
    public func update(tableView: UITableView) {
        let newVisibleSections = getVisibleSections()
        
        self.visibleSections = newVisibleSections
        tableView.reloadData()
    }
    
    private func updateVisibility() {
        self.visibleSections = getVisibleSections()
    }
    
    private func getVisibleSections() -> [Section] {
        var visibleSections = [Section]()
        
        for (sectionIndex, section) in sections.enumerated() {
            var visibleRows = [RowType]()
            
            for (rowIndex, row) in section.rows.enumerated() {
                let cellDescriptor = cellDescriptors[row.identifier]
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                let isHidden = cellDescriptor?.isHiddenClosure?(row, indexPath) ?? false
                
                if !isHidden {
                    visibleRows.append(row)
                }
            }
            
            section.update(visibleRows: visibleRows)
            
            let isHidden = section.isHiddenClosure?(section, sectionIndex) ?? false
            
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

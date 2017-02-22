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
    
    private(set) var sections: [Section<Any>] = []
    private var cellDescriptors: [String: CellDescriptorType] = [:]
    
    // MARK: Fallback UITableViewDataSource
    
    public var configure: ((RowType, UITableViewCell, IndexPath) -> Void)? = nil
    
    public var fallbackDataSource: UITableViewDataSource? = nil
    
    // MARK: Fallback UITableViewDelegate
    
    public var didSelect: ((RowType, IndexPath) -> SelectionResult)? = nil
    
    public var fallbackDelegate: UITableViewDelegate? = nil
    
    // MARK: Init
    
    public init(sections: [Section<Any>], cellDescriptors: [CellDescriptorType]) {
        self.sections = sections
        
        for d in cellDescriptors {
            self.cellDescriptors[d.rowIdentifier] = d
        }
    }
    
    // MARK: Getters
    
    public func row(at indexPath: IndexPath) -> RowType {
        return sections[indexPath.section][indexPath.row]
    }
    
    public var flattenedRows: [Item] {
        return sections.enumerated().flatMap { (section) -> [Item] in
            section.element.rows.enumerated().map { (row) in
                Item(indexPath: IndexPath(row: row.offset, section: section.offset), row: row.element as RowType)
            }
        }
    }
    
    // MARK: Cell Descriptors
    
    public func cellDescriptor(at indexPath: IndexPath) -> CellDescriptorType {
        let row = sections[indexPath.section].rows[indexPath.row]
        
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
    
    public func set(sections: [Section<Any>]) {
        self.sections = sections
    }
    
    public func replace(key: String? = nil, section: Section<Any>) {
        if let index = sections.index(where: { $0.key == key ?? section.key }) {
            self.sections[index] = section
        }
    }
    
    // MARK: Diff
    
    public func diff(sections: [Section<Any>]) -> NestedExtendedDiff {
        let oldSections = self.sections
        
        let diff = oldSections.nestedExtendedDiff(
            to: sections,
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

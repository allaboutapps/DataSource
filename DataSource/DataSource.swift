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
    
    private(set) var sections: [Section<Any>]
    private let configurators: [String: CellConfigurator]
    
    // MARK: Fallback closures
    
    public var didSelect: ((RowType, IndexPath) -> SelectionResult)? = nil
    
    // MARK: Init
    
    public init(sections: [Section<Any>], configurators: [CellConfigurator]) {
        self.sections = sections
        
        var dict = [String: CellConfigurator]()
        for c in configurators {
            dict[c.rowIdentifier] = c
        }
        self.configurators = dict
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
    
    // MARK: Configurators
    
    public func configurator(at indexPath: IndexPath) -> CellConfigurator {
        let row = sections[indexPath.section].rows[indexPath.row]
        
        if let configurator = configurators[row.identifier] {
            return configurator
        } else {
            fatalError("[DataSource] no configurator found for indexPath \(indexPath)")
        }
    }
    
    public func configurator(for rowIdentifier: String) -> CellConfigurator {
        if let configurator = configurators[rowIdentifier] {
            return configurator
        } else {
            fatalError("[DataSource] no configurator found for rowIdentifier \(rowIdentifier)")
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

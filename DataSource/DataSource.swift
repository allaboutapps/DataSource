//
//  DataSource.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Diff

public class DataSource {
    
    public struct Item {
        let indexPath: IndexPath
        let row: RowType
    }
    
    private(set) var sections: [Section<Any>]
    
    let configurators: [String: CellConfigurator]
    
    public init(sections: [Section<Any>], configurators: [CellConfigurator]) {
        self.sections = sections
        
        var dict = [String: CellConfigurator]()
        for c in configurators {
            dict[c.rowIdentifier] = c
        }
        self.configurators = dict
    }
    
    public var items: [Item] {
        return sections.enumerated().flatMap { (section) -> [Item] in
            section.element.rows.enumerated().map { (row) in
                Item(indexPath: IndexPath(row: row.offset, section: section.offset), row: row.element as RowType)
            }
        }
    }
    
    func configure() {
        for item in items {
            print("\(item.indexPath): \(item.row)")
            
            if let configurator = configurators[item.row.identifier] {
                configurator.configure(item.row, nil)
            }
            
        }
    }
    
    public func set(sections: [Section<Any>]) {
        self.sections = sections
    }
    
    public func replace(key: String? = nil, section: Section<Any>) {
        if let index = sections.index(where: { $0.key == key ?? section.key }) {
            self.sections[index] = section
        }
    }
    
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

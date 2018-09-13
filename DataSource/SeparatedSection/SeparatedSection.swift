//
//  SeparatedSection.swift
//  DataSource
//
//  Created by Michael Heinzl on 11.09.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public struct Transition {
    public let from: Any?
    public let to: Any?

    public init(from: Any?, to: Any?) {
        self.from = from
        self.to = to
    }
    
    public var isFirst: Bool {
        return from == nil && to != nil
    }
    
    public var isLast: Bool {
        return from != nil && to == nil
    }
    
}

open class SeparatedSection: Section {

    public typealias StyleConfigureClosure = (Transition) -> SeparatorStyle
    
    let styleConfigureClosure: StyleConfigureClosure

    public static let defaultStyleConfigureClosure: StyleConfigureClosure = {
        let x: StyleConfigureClosure = { (transition) in
            if transition.isFirst || transition.isLast  {
                return SeparatorStyle(leftInset: 0.0)
            } else {
                return SeparatorStyle(leftInset: 16.0)
            }
        }
        return x
    }()
    
    public init(_ content: Any?, rows: [RowType], visibleRows: [RowType]?, identifier: String?, styleConfigureClosure: @escaping StyleConfigureClosure = SeparatedSection.defaultStyleConfigureClosure) {
        self.styleConfigureClosure = styleConfigureClosure
        super.init(content, rows: rows, visibleRows: visibleRows, identifier: identifier)
    }
    
    public convenience init(_ content: Any? = nil, items: [Any], rowIdentifier: String? = nil, sectionIdentifier: String? = nil, styleConfigureClosure: @escaping StyleConfigureClosure = SeparatedSection.defaultStyleConfigureClosure) {
        let rows = items.map { Row($0, identifier: rowIdentifier) as RowType }
        self.init(content, rows: rows, visibleRows: rows, identifier: sectionIdentifier, styleConfigureClosure: styleConfigureClosure)
    }
    
    override public func updateVisibility(sectionIndex: Int, dataSource: DataSource) {
        guard !rows.isEmpty else {
            self.visibleRows = []
            return
        }
        var visibleRows = [RowType]()
        
        var style = styleConfigureClosure(Transition(from: nil, to: rows.first!.item))
        visibleRows.append(SeparatorLineViewModel(diffIdentifier: "spacer-\(identifier)-first", style: style).row)
        
        for (rowIndex, row) in rows.enumerated() {
            let cellDescriptor = dataSource.cellDescriptors[row.identifier]
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            let isHidden = cellDescriptor?.isHiddenClosure?(row, indexPath) ?? dataSource.isRowHidden?(row, indexPath) ?? false
            
            if !isHidden {
                visibleRows.append(row)
                
                let spacerId: String
                // Use diffIdentifier of row and identifier of section for diffIdentifier of spacer
                // this prevents unintentional reordering of rows
                if let diffableRow = row.item as? Diffable {
                    spacerId = "spacer-\(identifier)-\(diffableRow.diffIdentifier)"
                } else {
                    spacerId = "spacer-\(UUID().uuidString)"
                }
                
                let nextRow: RowType?
                if rows.indices.contains(rowIndex + 1) {
                    nextRow = rows[rowIndex + 1]
                } else {
                    nextRow = nil
                }
                style = styleConfigureClosure(Transition(from: row.item, to: nextRow?.item))
                visibleRows.append(SeparatorLineViewModel(diffIdentifier: spacerId, style: style).row)
            }
        }
        
        print("#####")
        visibleRows.forEach { (row) in
            print(row.diffableItem?.diffIdentifier ?? "NO diffIdentifier")
        }
        print("#####")
        
        self.visibleRows = visibleRows
    }
    
}

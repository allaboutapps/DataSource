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

    public typealias StyleConfigureClosure = (Transition) -> SeparatorStyle?
    public typealias ViewConfigureClosure = (Transition) -> UIView?
    
    let styleConfigureClosure: StyleConfigureClosure?
    let viewConfigureClosure: ViewConfigureClosure?

    public static let defaultStyleConfigureClosure: StyleConfigureClosure = { (transition) in
        if transition.isFirst || transition.isLast  {
            return SeparatorStyle(leftInset: 0.0)
        } else {
            return SeparatorStyle(leftInset: 16.0)
        }
    }
    
    // inits using SeparatorStyle configure closure
    
    public init(_ content: Any?, rows: [RowType], visibleRows: [RowType]?, identifier: String?, styleConfigureClosure: @escaping StyleConfigureClosure = SeparatedSection.defaultStyleConfigureClosure) {
        self.styleConfigureClosure = styleConfigureClosure
        self.viewConfigureClosure = nil
        super.init(content, rows: rows, visibleRows: visibleRows, identifier: identifier)
    }
    
    public convenience init(_ content: Any? = nil, items: [Any], rowIdentifier: String? = nil, sectionIdentifier: String? = nil, styleConfigureClosure: @escaping StyleConfigureClosure = SeparatedSection.defaultStyleConfigureClosure) {
        let rows = items.map { Row($0, identifier: rowIdentifier) as RowType }
        self.init(content, rows: rows, visibleRows: rows, identifier: sectionIdentifier, styleConfigureClosure: styleConfigureClosure)
    }
    
    // inits using UIView configure closure
    
    public init(_ content: Any?, rows: [RowType], visibleRows: [RowType]?, identifier: String?, viewConfigureClosure: @escaping ViewConfigureClosure) {
        self.styleConfigureClosure = nil
        self.viewConfigureClosure = viewConfigureClosure
        super.init(content, rows: rows, visibleRows: visibleRows, identifier: identifier)
    }
    
    public convenience init(_ content: Any? = nil, items: [Any], rowIdentifier: String? = nil, sectionIdentifier: String? = nil, viewConfigureClosure: @escaping ViewConfigureClosure) {
        let rows = items.map { Row($0, identifier: rowIdentifier) as RowType }
        self.init(content, rows: rows, visibleRows: rows, identifier: sectionIdentifier, viewConfigureClosure: viewConfigureClosure)
    }
    
    override public func updateVisibility(sectionIndex: Int, dataSource: DataSource) {
        guard !rows.isEmpty else {
            self.visibleRows = []
            return
        }
        var visibleRows = [RowType]()
        
        let _separatorViewModelRow = separatorViewModelRow(diffIdentifier: "separator-\(rows[0].diffableItem?.diffIdentifier ?? "")-first",
                                                           transition: Transition(from: nil, to: rows.first!.item))
        if let separatorViewModelRow = _separatorViewModelRow {
            visibleRows.append(separatorViewModelRow)
        }
        
        for (rowIndex, row) in rows.enumerated() {
            let cellDescriptor = dataSource.cellDescriptors[row.identifier]
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            let isHidden = cellDescriptor?.isHiddenClosure?(row, indexPath) ?? dataSource.isRowHidden?(row, indexPath) ?? false
            
            if !isHidden {
                visibleRows.append(row)
                
                let separatorId: String
                // Use diffIdentifier of row and identifier of section for diffIdentifier of separator
                // this prevents unintentional reordering of rows
                if let diffableRow = row.item as? Diffable {
                    separatorId = "separator-\(identifier)-\(diffableRow.diffIdentifier)"
                } else {
                    separatorId = "separator-\(UUID().uuidString)"
                }
                
                let nextRow: RowType?
                if rows.indices.contains(rowIndex + 1) {
                    nextRow = rows[rowIndex + 1]
                } else {
                    nextRow = nil
                }
                
                let _separatorViewModelRow = separatorViewModelRow(diffIdentifier: separatorId,
                                                                   transition: Transition(from: row.item, to: nextRow?.item))
                
                if let separatorViewModelRow = _separatorViewModelRow {
                    visibleRows.append(separatorViewModelRow)
                }
            }
        }
        
        self.visibleRows = visibleRows
    }
    
    private func separatorViewModelRow(diffIdentifier: String, transition: Transition) -> RowType? {
        if let styleConfigureClosure = styleConfigureClosure {
            if let style = styleConfigureClosure(transition) {
                return SeparatorLineViewModel(diffIdentifier: diffIdentifier, style: style).row
            } else {
                return nil
            }
        } else if let viewConfigureClosure = viewConfigureClosure {
            if let customView = viewConfigureClosure(transition) {
                return SeparatorCustomViewViewModel(diffIdentifier: diffIdentifier, customView: customView).row
            } else {
                return nil
            }
        } else {
            return SeparatorLineViewModel(diffIdentifier: diffIdentifier, style: SeparatedSection.defaultStyleConfigureClosure(transition)!).row
        }
    }
    
}

//
//  Section.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

// MARK: - SectionType

public protocol SectionType {
    
    var identifier: String { get }
    var content: Any? { get }
    var numberOfVisibleRows: Int { get }
    
    var diffableSection: DiffableSection { get }
    
    func row(at index: Int) -> RowType
    func visibleRow(at index: Int) -> RowType
    func updateVisibility(sectionIndex: Int, dataSource: DataSource)
}

// MARK: - Section

public class Section: SectionType {
    
    public let identifier: String
    public let content: Any?
    
    public private(set) var rows: [RowType] = []
    public private(set) var visibleRows: [RowType] = []
    
    public init(_ content: Any? = nil, rows: [RowType], visibleRows: [RowType]? = nil, identifier: String? = nil) {
        if let identifier = identifier {
            self.identifier = identifier
        } else if let content = content {
            self.identifier = String(describing: type(of: content))
        } else {
            self.identifier = ""
        }

        self.content = content
        self.rows = rows
        self.visibleRows = visibleRows ?? rows
    }
    
    public convenience init(_ content: Any? = nil, items: [Any], rowIdentifier: String? = nil, sectionIdentifier: String? = nil) {
        let rows = items.map { Row($0, identifier: rowIdentifier) as RowType }
        self.init(content, rows: rows, visibleRows: rows, identifier: sectionIdentifier)
    }
    
    public func with(identifier: String) -> Section {
        return Section(content, rows: rows, visibleRows: visibleRows, identifier: identifier)
    }

    public var numberOfVisibleRows: Int {
        return visibleRows.count
    }
    
    public func row(at index: Int) -> RowType {
        return rows[index]
    }
    
    public func visibleRow(at index: Int) -> RowType {
        return visibleRows[index]
    }

    // MARK: Update & Visibility
    
    public func update(rows: [RowType]) {
        self.rows = rows
        self.visibleRows = rows
    }
    
    public func updateVisibility(sectionIndex: Int, dataSource: DataSource) {
        var visibleRows = [RowType]()
        
        for (rowIndex, row) in rows.enumerated() {
            let cellDescriptor = dataSource.cellDescriptors[row.identifier]
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            let isHidden = cellDescriptor?.isHiddenClosure?(row, indexPath) ?? dataSource.isRowHidden?(row, indexPath) ?? false
            
            if !isHidden {
                visibleRows.append(row)
            }
        }
        
        self.visibleRows = visibleRows
    }
    
    public var diffableSection: DiffableSection {
        let visibleRows = self.visibleRows
        return DiffableSection(identifier: identifier, content: content, rowCount: visibleRows.count, rowClosure: { visibleRows[$0] })
    }
}

// MARK: - LazySectionType

public protocol LazySectionType: SectionType {
    
    var rowCount: () -> Int { get }
    var rowClosure: (Int) -> LazyRowType { get }
}

// MARK: - LazySection

public class LazySection: LazySectionType {
    
    public let identifier: String
    public let content: Any?
    
    public let rowCount: () -> Int
    public let rowClosure: (Int) -> LazyRowType
    
    public init(_ content: Any? = nil, count: @escaping () -> Int, row: @escaping (Int) -> LazyRowType, identifier: String? = nil) {
        if let identifier = identifier {
            self.identifier = identifier
        } else if let content = content {
            self.identifier = String(describing: type(of: content))
        } else {
            self.identifier = ""
        }
        
        self.content = content
        self.rowCount = count
        self.rowClosure = row
    }
    
    public func with(identifier: String) -> LazySection {
        return LazySection(content, count: rowCount, row: rowClosure, identifier: identifier)
    }
    
    public var anyContent: Any? {
        return content
    }
    
    public var numberOfVisibleRows: Int {
        return rowCount()
    }
    
    // there is no difference between row and visibleRow for on-demand sections,
    // you should only return visible rows
    
    public func row(at index: Int) -> RowType {
        return rowClosure(index)
    }
    
    public func visibleRow(at index: Int) -> RowType {
        return rowClosure(index)
    }
    
    // MARK: Update & Visibility
    
    public func updateVisibility(sectionIndex: Int, dataSource: DataSource) {
        // nope - not supported for LazySections, the rowClosure should only return visible rows
    }
    
    public var diffableSection: DiffableSection {
        return DiffableSection(identifier: identifier, content: content, rowCount: rowCount(), rowClosure: { _ in Row(()) })
    }
}

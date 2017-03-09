//
//  Section.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public enum HeaderFooter {
    case none
    case title(String)
    case view(UIView)
}

// MARK: - SectionType

public protocol SectionType {
    
    var key: String { get }
    var numberOfVisibleRows: Int { get }
    
    func row(at index: Int) -> RowType
    func visibleRow(at index: Int) -> RowType
    func updateVisibility(sectionIndex: Int, dataSource: DataSource)
    
    var isHiddenClosure: ((SectionType, Int) -> Bool)? { get }
    var headerClosure: ((SectionType, Int) -> HeaderFooter)? { get }
    var footerClosure: ((SectionType, Int) -> HeaderFooter)? { get }
    
    var diffableSection: DiffableSection { get }
}

// MARK: - Section

public class Section: SectionType {
    
    public let key: String
    
    public private(set) var rows: [RowType] = []
    public private(set) var visibleRows: [RowType] = []
    
    public init(key: String, rows: [RowType], visibleRows: [RowType]? = nil) {
        self.key = key
        self.rows = rows
        self.visibleRows = visibleRows ?? rows
    }
    
    public convenience init<Model>(key: String, models: [Model], rowIdentifier: String? = nil) {
        self.init(key: key, rows: models.map {
            Row($0, identifier: rowIdentifier)
        })
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
        return DiffableSection(key: key, rowCount: visibleRows.count, rowClosure: { self.visibleRow(at: $0) })
    }
    
    // MARK: Typed Getter
    
    private func typedSection(_ section: SectionType) -> Section {
        guard let section = section as? Section else {
            fatalError("[DataSource] could not cast to expected section type \(Section.self)")
        }
        return section
    }
    
    // MARK: isHidden
    
    public private(set) var isHiddenClosure: ((SectionType, Int) -> Bool)?
    
    public func isHidden(_ closure: @escaping (Section, Int) -> Bool) -> Section {
        isHiddenClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func isHidden(_ closure: @escaping () -> Bool) -> Section {
        isHiddenClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: Header
    
    public private(set) var headerClosure: ((SectionType, Int) -> HeaderFooter)?
    
    public func header(_ closure: @escaping (Section, Int) -> HeaderFooter) -> Section {
        headerClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func header(_ closure: @escaping () -> HeaderFooter) -> Section {
        headerClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: Footer
    
    public private(set) var footerClosure: ((SectionType, Int) -> HeaderFooter)?
    
    public func footer(_ closure: @escaping (Section, Int) -> HeaderFooter) -> Section {
        footerClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func footer(_ closure: @escaping () -> HeaderFooter) -> Section {
        footerClosure = { (_, _) in
            closure()
        }
        return self
    }
}

// MARK: - OnDemandSection

public class OnDemandSection: SectionType {
    
    public let key: String
    
    private let rowCount: () -> Int
    private let rowClosure: (Int) -> RowType
    private let diffableRowClosure: ((Int) -> RowType)?
    
    public init(key: String, rowCount: @escaping () -> Int, rowClosure: @escaping (Int) -> RowType, diffableRowClosure: ((Int) -> RowType)? = nil) {
        self.key = key
        self.rowCount = rowCount
        self.rowClosure = rowClosure
        self.diffableRowClosure = diffableRowClosure
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
        // nope
    }
    
    public var diffableSection: DiffableSection {
        return DiffableSection(key: key, rowCount: rowCount(), rowClosure: { (index) in
            return self.diffableRowClosure?(index) ?? Row(())
        })
    }
    
    // MARK: Typed Getter
    
    private func typedSection(_ section: SectionType) -> OnDemandSection {
        guard let section = section as? OnDemandSection else {
            fatalError("[DataSource] could not cast to expected section type \(Section.self)")
        }
        return section
    }
    
    // MARK: isHidden (not supported)
    
    public private(set) var isHiddenClosure: ((SectionType, Int) -> Bool)?
    
    // MARK: Header
    
    public private(set) var headerClosure: ((SectionType, Int) -> HeaderFooter)?
    
    public func header(_ closure: @escaping (OnDemandSection, Int) -> HeaderFooter) -> OnDemandSection {
        headerClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func header(_ closure: @escaping () -> HeaderFooter) -> OnDemandSection {
        headerClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: Footer
    
    public private(set) var footerClosure: ((SectionType, Int) -> HeaderFooter)?
    
    public func footer(_ closure: @escaping (OnDemandSection, Int) -> HeaderFooter) -> OnDemandSection {
        footerClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func footer(_ closure: @escaping () -> HeaderFooter) -> OnDemandSection {
        footerClosure = { (_, _) in
            closure()
        }
        return self
    }
}

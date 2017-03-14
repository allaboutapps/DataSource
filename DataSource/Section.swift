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

public enum SectionHeight {
    case value(_: CGFloat)
    case automatic
    case zero
    
    func floatValue(for style: UITableViewStyle) -> CGFloat {
        switch self {
        case .value(let value):
            return value
        case .automatic:
            return UITableViewAutomaticDimension
        case .zero:
            return style == .plain ? 0.0 : CGFloat.leastNormalMagnitude
        }
    }
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
    var headerHeightClosure: ((SectionType, Int) -> SectionHeight)? { get }
    var footerHeightClosure: ((SectionType, Int) -> SectionHeight)? { get }
    var willDisplayHeaderClosure: ((SectionType, UIView, Int) -> Void)? { get }
    var willDisplayFooterClosure: ((SectionType, UIView, Int) -> Void)? { get }

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
    
    public convenience init<Item>(key: String, items: [Item], rowIdentifier: String? = nil) {
        self.init(key: key, rows: items.map {
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
        let visibleRows = self.visibleRows
        return DiffableSection(key: key, rowCount: visibleRows.count, rowClosure: { visibleRows[$0] })
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
    
    // MARK: header
    
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
    
    // MARK: footer
    
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
    
    // MARK: headerHeight
    
    public private(set) var headerHeightClosure: ((SectionType, Int) -> SectionHeight)?
    
    public func headerHeight(_ closure: @escaping (Section, Int) -> SectionHeight) -> Section {
        headerHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func headerHeight(_ closure: @escaping () -> SectionHeight) -> Section {
        headerHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: footerHeight
    
    public private(set) var footerHeightClosure: ((SectionType, Int) -> SectionHeight)?
    
    public func footerHeight(_ closure: @escaping (Section, Int) -> SectionHeight) -> Section {
        footerHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func footerHeight(_ closure: @escaping () -> SectionHeight) -> Section {
        footerHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: willDisplayHeader
    
    public private(set) var willDisplayHeaderClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func willDisplayHeader(_ closure: @escaping (Section, UIView, Int) -> Void) -> Section {
        willDisplayHeaderClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func willDisplayHeader(_ closure: @escaping () -> Void) -> Section {
        willDisplayHeaderClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: willDisplayFooter
    
    public private(set) var willDisplayFooterClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func willDisplayFooter(_ closure: @escaping (Section, UIView, Int) -> Void) -> Section {
        willDisplayFooterClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func willDisplayFooter(_ closure: @escaping () -> Void) -> Section {
        willDisplayFooterClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: didEndDisplayingHeader
    
    public private(set) var didEndDisplayingHeaderClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func didEndDisplayingHeader(_ closure: @escaping (Section, UIView, Int) -> Void) -> Section {
        didEndDisplayingHeaderClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func didEndDisplayingHeader(_ closure: @escaping () -> Void) -> Section {
        didEndDisplayingHeaderClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: didEndDisplayingFooter
    
    public private(set) var didEndDisplayingFooterClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func didEndDisplayingFooter(_ closure: @escaping (Section, UIView, Int) -> Void) -> Section {
        didEndDisplayingFooterClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func didEndDisplayingFooter(_ closure: @escaping () -> Void) -> Section {
        didEndDisplayingFooterClosure = { (_, _, _) in
            closure()
        }
        return self
    }
}

// MARK: - LazySection

public class LazySection: SectionType {
    
    public let key: String
    
    private let rowCount: () -> Int
    private let rowClosure: (Int) -> LazyRowType
    
    public init(key: String, count: @escaping () -> Int, row: @escaping (Int) -> LazyRowType) {
        self.key = key
        self.rowCount = count
        self.rowClosure = row
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
        return DiffableSection(key: key, rowCount: rowCount(), rowClosure: { _ in Row(()) })
    }
    
    // MARK: Typed Getter
    
    private func typedSection(_ section: SectionType) -> LazySection {
        guard let section = section as? LazySection else {
            fatalError("[DataSource] could not cast to expected section type \(Section.self)")
        }
        return section
    }
    
    // MARK: isHidden (not supported)
    
    public private(set) var isHiddenClosure: ((SectionType, Int) -> Bool)?
    
    // MARK: header
    
    public private(set) var headerClosure: ((SectionType, Int) -> HeaderFooter)?
    
    public func header(_ closure: @escaping (LazySection, Int) -> HeaderFooter) -> LazySection {
        headerClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func header(_ closure: @escaping () -> HeaderFooter) -> LazySection {
        headerClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: footer
    
    public private(set) var footerClosure: ((SectionType, Int) -> HeaderFooter)?
    
    public func footer(_ closure: @escaping (LazySection, Int) -> HeaderFooter) -> LazySection {
        footerClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func footer(_ closure: @escaping () -> HeaderFooter) -> LazySection {
        footerClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: headerHeight
    
    public private(set) var headerHeightClosure: ((SectionType, Int) -> SectionHeight)?
    
    public func headerHeight(_ closure: @escaping (LazySection, Int) -> SectionHeight) -> LazySection {
        headerHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func headerHeight(_ closure: @escaping () -> SectionHeight) -> LazySection {
        headerHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: estimatedHeaderHeight
    
    public private(set) var estimatedHeaderHeightClosure: ((SectionType, Int) -> SectionHeight)?
    
    public func estimatedHeaderHeight(_ closure: @escaping (LazySection, Int) -> SectionHeight) -> LazySection {
        estimatedHeaderHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func estimatedHeaderHeight(_ closure: @escaping () -> SectionHeight) -> LazySection {
        estimatedHeaderHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: footerHeight
    
    public private(set) var footerHeightClosure: ((SectionType, Int) -> SectionHeight)?
    
    public func footerHeight(_ closure: @escaping (LazySection, Int) -> SectionHeight) -> LazySection {
        footerHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func footerHeight(_ closure: @escaping () -> SectionHeight) -> LazySection {
        footerHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: estimatedFooterHeight
    
    public private(set) var estimatedFooterHeightClosure: ((SectionType, Int) -> CGFloat)?
    
    public func estimatedFooterHeight(_ closure: @escaping (LazySection, Int) -> CGFloat) -> LazySection {
        estimatedFooterHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func estimatedFooterHeight(_ closure: @escaping () -> CGFloat) -> LazySection {
        estimatedFooterHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: willDisplayHeader
    
    public private(set) var willDisplayHeaderClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func willDisplayHeader(_ closure: @escaping (LazySection, UIView, Int) -> Void) -> LazySection {
        willDisplayHeaderClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func willDisplayHeader(_ closure: @escaping () -> Void) -> LazySection {
        willDisplayHeaderClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: willDisplayFooter
    
    public private(set) var willDisplayFooterClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func willDisplayFooter(_ closure: @escaping (LazySection, UIView, Int) -> Void) -> LazySection {
        willDisplayFooterClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func willDisplayFooter(_ closure: @escaping () -> Void) -> LazySection {
        willDisplayFooterClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: didEndDisplayingHeader
    
    public private(set) var didEndDisplayingHeaderClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func didEndDisplayingHeader(_ closure: @escaping (LazySection, UIView, Int) -> Void) -> LazySection {
        didEndDisplayingHeaderClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func didEndDisplayingHeader(_ closure: @escaping () -> Void) -> LazySection {
        didEndDisplayingHeaderClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: didEndDisplayingFooter
    
    public private(set) var didEndDisplayingFooterClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func didEndDisplayingFooter(_ closure: @escaping (LazySection, UIView, Int) -> Void) -> LazySection {
        didEndDisplayingFooterClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func didEndDisplayingFooter(_ closure: @escaping () -> Void) -> LazySection {
        didEndDisplayingFooterClosure = { (_, _, _) in
            closure()
        }
        return self
    }
}

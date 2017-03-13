//
//  OnDemandSection.swift
//  DataSource
//
//  Created by Matthias Buchetics on 09/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public class OnDemandSection: SectionType {
    
    public let key: String
    
    private let rowCount: () -> Int
    private let rowClosure: (Int) -> RowType
    
    public init(key: String, rowCount: @escaping () -> Int, rowClosure: @escaping (Int) -> RowType) {
        self.key = key
        self.rowCount = rowCount
        self.rowClosure = rowClosure
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
        return DiffableSection(key: key, rowCount: rowCount(), rowClosure: { _ in Row(()) })
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
    
    // MARK: header
    
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
    
    // MARK: footer
    
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
    
    // MARK: headerHeight
    
    public private(set) var headerHeightClosure: ((SectionType, Int) -> CGFloat)?
    
    public func headerHeight(_ closure: @escaping (OnDemandSection, Int) -> CGFloat) -> OnDemandSection {
        headerHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func headerHeight(_ closure: @escaping () -> CGFloat) -> OnDemandSection {
        headerHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: estimatedHeaderHeight
    
    public private(set) var estimatedHeaderHeightClosure: ((SectionType, Int) -> CGFloat)?
    
    public func estimatedHeaderHeight(_ closure: @escaping (OnDemandSection, Int) -> CGFloat) -> OnDemandSection {
        estimatedHeaderHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func estimatedHeaderHeight(_ closure: @escaping () -> CGFloat) -> OnDemandSection {
        estimatedHeaderHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: footerHeight
    
    public private(set) var footerHeightClosure: ((SectionType, Int) -> CGFloat)?
    
    public func footerHeight(_ closure: @escaping (OnDemandSection, Int) -> CGFloat) -> OnDemandSection {
        footerHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func footerHeight(_ closure: @escaping () -> CGFloat) -> OnDemandSection {
        footerHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: estimatedFooterHeight
    
    public private(set) var estimatedFooterHeightClosure: ((SectionType, Int) -> CGFloat)?
    
    public func estimatedFooterHeight(_ closure: @escaping (OnDemandSection, Int) -> CGFloat) -> OnDemandSection {
        estimatedFooterHeightClosure = { (section, index) in
            closure(self.typedSection(section), index)
        }
        return self
    }
    
    public func estimatedFooterHeight(_ closure: @escaping () -> CGFloat) -> OnDemandSection {
        estimatedFooterHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: willDisplayHeader
    
    public private(set) var willDisplayHeaderClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func willDisplayHeader(_ closure: @escaping (OnDemandSection, UIView, Int) -> Void) -> OnDemandSection {
        willDisplayHeaderClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func willDisplayHeader(_ closure: @escaping () -> Void) -> OnDemandSection {
        willDisplayHeaderClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: willDisplayFooter
    
    public private(set) var willDisplayFooterClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func willDisplayFooter(_ closure: @escaping (OnDemandSection, UIView, Int) -> Void) -> OnDemandSection {
        willDisplayFooterClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func willDisplayFooter(_ closure: @escaping () -> Void) -> OnDemandSection {
        willDisplayFooterClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: didEndDisplayingHeader
    
    public private(set) var didEndDisplayingHeaderClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func didEndDisplayingHeader(_ closure: @escaping (OnDemandSection, UIView, Int) -> Void) -> OnDemandSection {
        didEndDisplayingHeaderClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func didEndDisplayingHeader(_ closure: @escaping () -> Void) -> OnDemandSection {
        didEndDisplayingHeaderClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: didEndDisplayingFooter
    
    public private(set) var didEndDisplayingFooterClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func didEndDisplayingFooter(_ closure: @escaping (OnDemandSection, UIView, Int) -> Void) -> OnDemandSection {
        didEndDisplayingFooterClosure = { (section, view, index) in
            closure(self.typedSection(section), view, index)
        }
        return self
    }
    
    public func didEndDisplayingFooter(_ closure: @escaping () -> Void) -> OnDemandSection {
        didEndDisplayingFooterClosure = { (_, _, _) in
            closure()
        }
        return self
    }
}

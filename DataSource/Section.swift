//
//  Section.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public class Section {
    
    public enum HeaderFooter {
        case none
        case title(String)
        case view(UIView)
    }
    
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
    
    internal var diffClone: Section {
        return Section(key: key, rows: rows, visibleRows: visibleRows)
    }
    
    public func update(rows: [RowType]) {
        self.rows = rows
        self.visibleRows = rows
    }
    
    internal func update(visibleRows: [RowType]) {
        self.visibleRows = visibleRows
    }
    
    // MARK: - Closures
    
    // MARK: isHidden
    
    public private(set) var isHiddenClosure: ((Section, Int) -> Bool)?
    
    public func isHidden(_ closure: @escaping (Section, Int) -> Bool) -> Section {
        isHiddenClosure = closure
        return self
    }
    
    public func isHidden(_ closure: @escaping () -> Bool) -> Section {
        isHiddenClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: Header
    
    public private(set) var headerClosure: ((Section, Int) -> HeaderFooter)?
    
    public func header(_ closure: @escaping (Section, Int) -> HeaderFooter) -> Section {
        headerClosure = closure
        return self
    }
    
    public func header(_ closure: @escaping () -> HeaderFooter) -> Section {
        headerClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: Footer
    
    public private(set) var footerClosure: ((Section, Int) -> HeaderFooter)?
    
    public func footer(_ closure: @escaping (Section, Int) -> HeaderFooter) -> Section {
        footerClosure = closure
        return self
    }
    
    public func footer(_ closure: @escaping () -> HeaderFooter) -> Section {
        footerClosure = { (_, _) in
            closure()
        }
        return self
    }
}

// MARK: - Equatable

extension Section: Equatable {
    
    public static func ==(lhs: Section, rhs: Section) -> Bool {
        return lhs.key == rhs.key
    }
}

// MARK: - Collection

extension Section: Collection {
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return visibleRows.startIndex
    }
    
    public var endIndex: Int {
        return visibleRows.endIndex
    }
    
    public subscript(i: Int) -> RowType {
        return visibleRows[i]
    }
    
    public func index(after i: Int) -> Int {
        return visibleRows.index(after: i)
    }
}

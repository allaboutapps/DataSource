//
//  Section.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public class Section: Collection {
    
    public enum HeaderFooter {
        case none
        case title(String)
        case view(UIView)
    }
    
    public let key: String
    public let rows: [RowType]
    
    public init(key: String, rows: [RowType]) {
        self.key = key
        self.rows = rows
    }
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return rows.startIndex
    }
    
    public var endIndex: Int {
        return rows.endIndex
    }
    
    public subscript(i: Int) -> RowType {
        return rows[i]
    }
    
    public func index(after i: Int) -> Int {
        return rows.index(after: i)
    }
    
    public static func ==(a: Section, b: Section) -> Bool {
        return a.key == b.key
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

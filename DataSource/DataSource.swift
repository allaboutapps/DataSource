//
//  DataSource.swift
//  DataSource
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

// MARK: - Protocols

// MARK: RowType
public protocol RowType {

    var identifier: String { get }
    var anyData: Any { get }
}

// MARK: SectionType
public protocol SectionType {

    var title: String? { get }
    var footer: String? { get }
    var numberOfRows: Int { get }
    
    subscript(index: Int) -> RowType { get }
}

// MARK: DataSourceType
public protocol DataSourceType {

    var numberOfSections: Int { get }
    var firstSection: SectionType? { get }
    var lastSection: SectionType? { get }
    
    func section<T>(at indexPath: IndexPath) -> Section<T>
    func section(at indexPath: IndexPath) -> SectionType
    func section<T>(at index: Int) -> Section<T>
    func section(at index: Int) -> SectionType
    
    func numberOfRows(in section: Int) -> Int
    func row(at indexPath: IndexPath) -> RowType
    func row<T>(at indexPath: IndexPath) -> Row<T>
}

// MARK: - Row

/**
    Representation of a table row which encapsulates your data (e.g. view model) and an identifier for the row.
    The identifier is used to find a matching cell configurator to configure the specific row, i.e. multiple rows
    of the same type usually share the same identifier.
*/
public struct Row<T>: RowType {

    public let identifier: String
    public let data: T
    
    public init(identifier: String, data: T) {
        self.identifier = identifier
        self.data = data
    }
    
    public var anyData: Any {
        return data
    }
}

// MARK: - Section

/**
    Representation of a table section containing multiple rows with an optional title.
*/
public struct Section<T>: SectionType {

    /// Array of typed rows
    public let rows: [Row<T>]
    
    /// Title of the section
    public let title: String?
    
    /// Footer of the section
    public let footer: String?
    
    /// Closure which returns a row given its index
    public let rowCreatorClosure: ((_ rowIndex: Int) -> Row<T>)?
    
    /// Closure which returns the total number of rows
    public let rowCountClosure: (() -> Int)?
    
    /// Initializes an empty section
    public init() {
        self.rows = []
        self.title = nil
        self.footer = nil
        self.rowCreatorClosure = nil
        self.rowCountClosure = nil
    }
    
    /// Initializes a section with an array of rows and an optional title and footer
    public init(title: String? = nil, footer: String? = nil, rows: [Row<T>]) {
        self.rows = rows
        self.title = title
        self.footer = footer
        self.rowCreatorClosure = nil
        self.rowCountClosure = nil
    }
    
    /// Initializes a section with an array of models (or view models) which are encapsulated in rows using the specified row identifier
    public init(title: String? = nil, footer: String? = nil, rowIdentifier: String, rows: [T]) {
        self.init(title: title, footer: footer, rows: rows.dataSourceRows(rowIdentifier: rowIdentifier))
    }
    
    /// Initializes a section with a row creator closure
    public init(title: String? = nil, footer: String? = nil, rowCountClosure: @escaping (() -> Int), rowCreatorClosure: @escaping (Int) -> Row<T>) {
        self.rows = []
        self.title = title
        self.footer = footer
        self.rowCountClosure = rowCountClosure
        self.rowCreatorClosure = rowCreatorClosure
    }
    
    public func row(at index: Int) -> Row<T> {
        if let creator = rowCreatorClosure {
            return creator(index)
        } else {
            return rows[index]
        }
    }
    
    public subscript(index: Int) -> Row<T> {
        return row(at: index)
    }
    
    public subscript(index: Int) -> RowType {
        return row(at: index)
    }
    
    public var numberOfRows: Int {
        if let count = rowCountClosure {
            return count()
        } else {
            return rows.count
        }
    }
}

// MARK: - Data Source

/**
    Representation of a data source containing multiple sections.
*/
public struct DataSource: DataSourceType {

    /// Array of sections
    fileprivate var sections: [SectionType]
    
    /// Initializes an empty data source (no sections)
    public init() {
        self.sections = []
    }
    
    /// Initializes a data source with a single section
    public init(section: SectionType) {
        self.sections = [section]
    }
    
    /// Initializes a data source with multiple sections
    public init(sections: [SectionType]) {
        self.sections = sections
    }
    
    /// Initializes a data source with multiple other data sources by concatinating their sections
    public init(dataSources: [DataSource]) {
        self.init()
        
        for dataSource in dataSources {
            append(dataSource: dataSource)
        }
    }
    
    // MARK: Rows
    
    public func numberOfRows(in section: Int) -> Int {
        return sections[section].numberOfRows
    }
    
    public func row(at indexPath: IndexPath) -> RowType {
        return sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }
    
    public func row<T>(at indexPath: IndexPath) -> Row<T> {
        let section = sections[(indexPath as NSIndexPath).section] as! Section<T>
        let row: Row<T> = section[(indexPath as NSIndexPath).row]
        return row
    }
    
    // MARK: Sections
    
    public var numberOfSections: Int {
        return sections.count
    }
    
    public var firstSection: SectionType? {
        return sections.first
    }
    
    public var lastSection: SectionType? {
        return sections.last
    }
    
    public func section<T>(at indexPath: IndexPath) -> Section<T> {
        return section(at: indexPath.section)
    }
    
    public func section(at indexPath: IndexPath) -> SectionType {
        return section(at: indexPath.section)
    }
    
    public func section<T>(at index: Int) -> Section<T> {
        return sections[index] as! Section<T>
    }
    
    public func section(at index: Int) -> SectionType {
        return sections[index]
    }
    
    // MARK: Mutating
    
    public mutating func append(section: SectionType) {
        sections.append(section)
    }
    
    public mutating func append(dataSource: DataSource) {
        sections.append(contentsOf: dataSource.sections)
    }
    
    public mutating func insert(section: SectionType, at index: Int) {
        sections.insert(section, at: index)
    }
    
    public mutating func replace(section: SectionType, at index: Int) {
        sections[index] = section
    }
    
    public mutating func removeSection(at index: Int) {
        sections.remove(at: index)
    }
}

// MARK: CustomDebugStringConvertible

extension DataSource: CustomDebugStringConvertible {

    public var debugDescription: String {
        var text = ""
        
        for section in sections {
            let title = section.title ?? "(unnamed section)"
            text += "\n\(title)"
            
            for index in 0..<section.numberOfRows {
                let row = section[index]
                text += "\n  \(row)"
            }
        }
        
        return text
    }
}

// MARK: - Extensions

extension SectionType {

    public var hasTitle: Bool {
        if let title = title, !title.isEmpty {
            return true
        } else {
            return false
        }
    }

    public var hasFooter: Bool {
        if let footer = footer, !footer.isEmpty {
            return true
        } else {
            return false
        }
    }
}

extension Section {

    /// Converts a section into a data source (with a single section)
    public func dataSource() -> DataSource {
        return DataSource(section: self)
    }
}

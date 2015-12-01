//
//  DataSource.swift
//  DataSource
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

// MARK: - Protocols

public protocol RowType {
    var identifier: String { get }
    var anyData: Any { get }
}

public protocol SectionType {
    var title: String? { get }
    var hasTitle: Bool { get }
    var numberOfRows: Int { get }
    
    subscript(index: Int) -> RowType { get }
}

public protocol DataSourceType {
    var numberOfSections: Int { get }
    var firstSection: SectionType? { get }
    var lastSection: SectionType? { get }
    
    func sectionAtIndexPath<T>(indexPath: NSIndexPath) -> Section<T>
    func sectionAtIndexPath(indexPath: NSIndexPath) -> SectionType
    func sectionAtIndex<T>(index: Int) -> Section<T>
    func sectionAtIndex(index: Int) -> SectionType
    
    func numberOfRowsInSection(section: Int) -> Int
    func rowAtIndexPath(indexPath: NSIndexPath) -> RowType
    func rowAtIndexPath<T>(indexPath: NSIndexPath) -> Row<T>
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
    public let rows: Array<Row<T>>
    
    /// Optional title of the section
    public let title: String?
    
    /// Initializes an empty section
    public init() {
        self.rows = []
        self.title = nil
    }
    
    /// Initializes a section with an array of rows and an optional title
    public init(title: String? = nil, rows: Array<Row<T>>) {
        self.rows = rows
        self.title = title
    }
    
    /// Initializes a section with an array of models (or view models) which are encapsulated in rows using the specified row identifier
    public init(title: String? = nil, rowIdentifier: String, rows: Array<T>) {
        self.rows = rows.toDataSourceRows(rowIdentifier)
        self.title = title
    }
    
    public subscript(index: Int) -> Row<T> {
        return rows[index]
    }
    
    public subscript(index: Int) -> RowType {
        return rows[index]
    }
    
    public var numberOfRows: Int {
        return rows.count
    }
    
    public var hasTitle: Bool {
        if let title = title where !title.isEmpty {
            return true
        }
        else {
            return false
        }
    }
}

// MARK: - Data Source

/**
    Representation of a data source containing multiple sections.
*/
public struct DataSource: DataSourceType {
    /// Array of sections
    var sections: Array<SectionType>
    
    /// Initializes an empty data source (no sections)
    public init() {
        self.sections = []
    }
    
    /// Initializes a data source with a single section
    public init(_ section: SectionType) {
        self.sections = [section]
    }
    
    /// Initializes a data source with multiple sections
    public init(_ sections: Array<SectionType>) {
        self.sections = sections
    }
    
    /// Initializes a data source with multiple other data sources by concatinating their sections
    public init(dataSources: Array<DataSource>) {
        self.init()
        
        for dataSource in dataSources {
            appendDataSource(dataSource)
        }
    }
    
    // MARK: Rows
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return sections[section].numberOfRows
    }
    
    public func rowAtIndexPath(indexPath: NSIndexPath) -> RowType {
        return sections[indexPath.section][indexPath.row]
    }
    
    public func rowAtIndexPath<T>(indexPath: NSIndexPath) -> Row<T> {
        let section = sections[indexPath.section] as! Section<T>
        let row: Row<T> = section[indexPath.row]
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
    
    public func sectionAtIndexPath<T>(indexPath: NSIndexPath) -> Section<T> {
        return sectionAtIndex(indexPath.section)
    }
    
    public func sectionAtIndexPath(indexPath: NSIndexPath) -> SectionType {
        return sectionAtIndex(indexPath.section)
    }
    
    public func sectionAtIndex<T>(index: Int) -> Section<T> {
        return sections[index] as! Section<T>
    }
    
    public func sectionAtIndex(index: Int) -> SectionType {
        return sections[index]
    }
    
    // MARK: Mutating
    
    public mutating func appendSection(section: SectionType) {
        sections.append(section)
    }
    
    public mutating func appendDataSource(dataSource: DataSource) {
        sections.appendContentsOf(dataSource.sections)
    }
    
    public mutating func insertSection(section: SectionType, index: Int) {
        sections.insert(section, atIndex: index)
    }
    
    public mutating func setSection(section: SectionType, index: Int) {
        sections[index] = section
    }
    
    public mutating func removeSectionAtIndex(index: Int) {
        sections.removeAtIndex(index)
    }
}

// MARK: - Debugging

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

// MARK: - Convenience

extension Section {
    /// Converts a section into a data source (with a single section)
    public func toDataSource() -> DataSource {
        return DataSource(self)
    }
}
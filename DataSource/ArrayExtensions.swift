//
//  ArrayExtensions.swift
//  Example
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

extension Array {
    /// Transforms an array into typed data source rows
    public func toDataSourceRows(_ rowIdentifier: String) -> [Row<Element>] {
        return self.map { item in Row(identifier: rowIdentifier, data: item) }
    }
    
    /// Transforms an array into a typed data source section
    public func toDataSourceSection(_ rowIdentifier: String, title: String? = nil) -> Section<Element> {
        return Section(title: title, rows: self.toDataSourceRows(rowIdentifier))
    }
    
    /// Transforms an array into a data source (with a single section)
    public func toDataSource(_ rowIdentifier: String) -> DataSource {
        return DataSource(self.toDataSourceSection(rowIdentifier))
    }
}

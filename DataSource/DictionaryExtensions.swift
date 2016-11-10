//
//  DictionaryExtensions.swift
//  Example
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

extension Dictionary where Key: Any, Value: Collection {

    /**
        Simplifies the transformation of a dictionary (with arrays as values) into a data source.
        Because dictionaries are unordered, it's required to provide an array of ordered keys as well.
        Omitted keys will not be added to the data source.
     */
    public func dataSource(rowIdentifier: String, orderedKeys: [Key]) -> DataSource {
        var dataSource = DataSource()

        for key in orderedKeys {
            let values = self[key]!
            let rows = values.map { item in
                Row<Value.Iterator.Element>(identifier: rowIdentifier, data: item)
            }
            
            var title: String?
            
            if let key = key as? String {
                title = key
            } else if let key = key as? CustomStringConvertible {
                title = key.description
            }
            
            dataSource.append(section: Section(title: title, rows: rows))
        }

        return dataSource
    }
}

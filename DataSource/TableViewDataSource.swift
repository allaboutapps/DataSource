//
//  TableViewDataSource.swift
//  DataSource
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import UIKit

// MARK: - TableViewDataSource

/**
    Wraps a `DataSource` and uses `TableViewCellConfigurator`s to dequeue and configure table view cells.
    Implements `UITableViewDataSource` and `DataSourceType` protocols.
*/
open class TableViewDataSource: NSObject {
    /// The data source
    public var dataSource: DataSource
    
    /// Whether to show section titles
    public var showSectionTitles: Bool?

    /// Whether to show section titles
    public var showSectionFooters: Bool?

    /// Whether cells should be configured inside a UIView.performWithoutAnimation closure
    public var configureWithoutAnimations: Bool = true
    
    /// Optional closure which is called after a cell is dequeued, but before it's being configured (e.g. to "reset" a cell)
    public var prepareCell: ((UITableViewCell, IndexPath) -> Void)?

    /// Registered cell configurators
    var configurators = [String: TableViewCellConfiguratorType]()
    
    /// Initializes the table view data source with a single cell configurator
    public init(dataSource: DataSource, configurator: TableViewCellConfiguratorType) {
        self.dataSource = dataSource
        self.configurators[configurator.rowIdentifier] = configurator
    }
    
    /// Initializes the table view data source with multiple cell configurators
    public init(dataSource: DataSource, configurators: [TableViewCellConfiguratorType]) {
        self.dataSource = dataSource
        
        for configurator in configurators {
            self.configurators[configurator.rowIdentifier] = configurator
        }
    }
    
    /// Add a cell configurator
    public func addConfigurator(_ configurator: TableViewCellConfiguratorType) {
        configurators[configurator.rowIdentifier] = configurator
    }
    
    /**
        Tries to get the appropriate cell configurator given the specified row identifier.
        If no cell configurator for the specified row identifier is found, the default configurator with identifier "" (empty string) is used if available.
     */
    public func configuratorForRowIdentifier(_ rowIdentifier: String) -> TableViewCellConfiguratorType? {
        if let configurator = self.configurators[rowIdentifier] {
            return configurator
        } else if let configurator = self.configurators[""] {
            return configurator
        } else {
            return nil
        }
    }
}

// MARK: - UITableViewDataSource

extension TableViewDataSource: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRowsInSection(section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource.rowAtIndexPath(indexPath)

        let configure: () -> UITableViewCell = {
            if let configurator = self.configuratorForRowIdentifier(row.identifier) {
                let cell = tableView.dequeueReusableCell(withIdentifier: configurator.cellIdentifier, for: indexPath)
                self.prepareCell?(cell, indexPath)
                configurator.configure(row: row, cell: cell, indexPath: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier, for: indexPath)
                self.prepareCell?(cell, indexPath)
                return cell
            }
        }

        var cell: UITableViewCell? = nil

        if configureWithoutAnimations {
            UIView.performWithoutAnimation {
                cell = configure()
            }
        } else {
            cell = configure()
        }

        return cell!
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let showTitles = showSectionTitles ?? (tableView.style == .grouped || dataSource.numberOfSections > 1)
        
        if showTitles && dataSource.numberOfRowsInSection(section) > 0 {
            return dataSource.sections[section].title
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let showFooters = showSectionFooters ?? (tableView.style == .grouped || dataSource.numberOfSections > 1)
        
        if showFooters && dataSource.numberOfRowsInSection(section) > 0 {
            return dataSource.sections[section].footer
        } else {
            return nil
        }
    }
}

// MARK: - DataSourceType
extension TableViewDataSource: DataSourceType {
    // MARK: Rows
    
    public func numberOfRowsInSection(_ section: Int) -> Int {
        return dataSource.numberOfRowsInSection(section)
    }
    
    public func rowAtIndexPath(_ indexPath: IndexPath) -> RowType {
        return dataSource.rowAtIndexPath(indexPath)
    }
    
    public func rowAtIndexPath<T>(_ indexPath: IndexPath) -> Row<T> {
        return dataSource.rowAtIndexPath(indexPath)
    }
    
    // MARK: Sections
    
    public var numberOfSections: Int {
        return dataSource.numberOfSections
    }
    
    public var firstSection: SectionType? {
        return dataSource.firstSection
    }
    
    public var lastSection: SectionType? {
        return dataSource.lastSection
    }
    
    public func sectionAtIndexPath<T>(_ indexPath: IndexPath) -> Section<T> {
        return dataSource.sectionAtIndexPath(indexPath)
    }
    
    public func sectionAtIndexPath(_ indexPath: IndexPath) -> SectionType {
        return dataSource.sectionAtIndexPath(indexPath)
    }
    
    public func sectionAtIndex<T>(_ index: Int) -> Section<T> {
        return dataSource.sectionAtIndex(index)
    }
    
    public func sectionAtIndex(_ index: Int) -> SectionType {
        return dataSource.sectionAtIndex(index)
    }
}

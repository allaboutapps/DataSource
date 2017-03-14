//
//  DataSourceDiffable.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Diff

// MARK: - Diffable

public protocol Diffable {
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool
}

extension String: Diffable {
    
    public func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? String else { return false }
        return self == other
    }
}

// MARK: - DiffableSection

public struct DiffableSection {
    
    let key: String
    let rowCount: Int
    let rowClosure: (Int) -> RowType
}

extension DiffableSection: Equatable {
    
    public static func ==(lhs: DiffableSection, rhs: DiffableSection) -> Bool {
        return lhs.key == rhs.key
    }
}

extension DiffableSection: Collection {
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return rowCount
    }
    
    public subscript(i: Int) -> RowType {
        return rowClosure(i)
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
}

// MARK: - DataSource Extensions

extension DataSource {
    
    public func updateAnimated(sections: [SectionType]? = nil, tableView: UITableView, rowDeletionAnimation: UITableViewRowAnimation = .fade, rowInsertionAnimation: UITableViewRowAnimation = .fade, sectionDeletionAnimation: UITableViewRowAnimation = .fade, sectionInsertionAnimation: UITableViewRowAnimation = .fade) {
        
        if let sections = sections {
            self.allSections = sections
        }
        
        let oldSections = visibleSections.map { $0.diffableSection }
        let newSections = updateSectionVisiblity()
        let diffableNewSections = newSections.map { $0.diffableSection }
        
        let diff = computeDiff(oldSections: oldSections, newSections: diffableNewSections)
        
        self.visibleSections = newSections
        
        tableView.apply(diff, rowDeletionAnimation: rowDeletionAnimation, rowInsertionAnimation: rowInsertionAnimation, sectionDeletionAnimation: sectionDeletionAnimation, sectionInsertionAnimation: sectionInsertionAnimation)
    }
    
    public func computeDiff(oldSections: [SectionType], newSections: [SectionType]) -> NestedExtendedDiff {
        return computeDiff(oldSections: oldSections.map { $0.diffableSection }, newSections: newSections.map { $0.diffableSection })
    }
    
    private func computeDiff(oldSections: [DiffableSection], newSections: [DiffableSection]) -> NestedExtendedDiff {
        print("old sections")
        for section in oldSections {
            for row in section {
                print(row)
            }
        }
        
        print("new sections")
        for section in newSections {
            for row in section {
                print(row)
            }
        }
        
        let diff = oldSections.nestedExtendedDiff(
            to: newSections,
            isEqualSection: { (section1, section2) -> Bool in
                section1.key == section2.key
            },
            isEqualElement: { (row1, row2) -> Bool in
                guard
                    let a = row1.diffableItem,
                    let b = row2.diffableItem
                else {
                    return false
                }
                
                return a.isEqualToDiffable(b)
            })
        
        return diff
    }
}

//
//  DataSourceDiffable.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Diff

extension DataSource {
    
    public struct Item {
        
        let indexPath: IndexPath
        let row: RowType
    }
    
    struct ItemUpdate {
        
        let from: Item
        let to: Item
    }
    
    // MARK: Diff
    
    func computeDiff(oldSections: [SectionType], newSections: [SectionType]) -> NestedExtendedDiff {
        return computeDiff(oldSections: oldSections.map { $0.diffableSection }, newSections: newSections.map { $0.diffableSection })
    }
    
    func computeDiff(oldSections: [DiffableSection], newSections: [DiffableSection]) -> NestedExtendedDiff {
        let diff = oldSections.nestedExtendedDiff(
            to: newSections,
            isEqualSection: { (section1, section2) -> Bool in
                section1 == section2
            },
            isEqualElement: { (row1, row2) -> Bool in
                guard let a = row1.diffableItem, let b = row2.diffableItem else {
                    return false
                }
                
                return a.diffIdentifier == b.diffIdentifier
            })
        
        return diff
    }
    
    // MARK: Update
    
    func computeUpdate(oldSections: [DiffableSection], newSections: [DiffableSection]) -> [ItemUpdate] {
        let oldItems = flattenedItems(oldSections)
        let newItems = flattenedItems(newSections)
        
        return computeUpdate(oldItems: oldItems, newItems: newItems)
    }
    
    func computeUpdate(oldItems: [Item], newItems: [Item]) -> [ItemUpdate] {
        let oldSet = itemsByDiffIdentifier(oldItems)
        let newSet = itemsByDiffIdentifier(newItems)
        
        var result = [ItemUpdate]()
        
        for kvp in oldSet {
            let oldItem = kvp.value
            
            guard
                let newItem = newSet[kvp.key],
                let oldDiffable = oldItem.row.diffableItem,
                let newDiffable = newItem.row.diffableItem
                else {
                    continue
            }
            
            if oldDiffable.diffIdentifier == newDiffable.diffIdentifier, !oldDiffable.isEqualToDiffable(newDiffable) {
                result.append(ItemUpdate(from: oldItem, to: newItem))
            }
        }
        
        return result
    }

    
    func flattenedItems(_ sections: [DiffableSection]) -> [Item] {
        var result = [Item]()
        
        for (sectionIndex, section) in sections.enumerated() {
            for (rowIndex, row) in section.enumerated() {
                result.append(Item(indexPath: IndexPath(row: rowIndex, section: sectionIndex), row: row))
            }
        }
        
        return result
    }
    
    func itemsByDiffIdentifier(_ items: [Item]) -> [String: Item] {
        var result = [String: Item]()
        
        for item in items {
            if let diffIdentifier = item.row.diffableItem?.diffIdentifier, result[diffIdentifier] == nil {
                result[diffIdentifier] = item
            }
        }
        
        return result
    }
}

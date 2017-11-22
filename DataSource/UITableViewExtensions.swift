//
//  UITableViewExtensions.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import Diff

// MARK: - Batch

struct Batch {
    
    let itemDeletions: [IndexPath]
    let itemInsertions: [IndexPath]
    let itemMoves: [(from: IndexPath, to: IndexPath)]
    let itemUpdates: [IndexPath]
    let sectionDeletions: IndexSet
    let sectionInsertions: IndexSet
    let sectionMoves: [(from: Int, to: Int)]
    
    init(diff: NestedExtendedDiff, updates: [DataSource.ItemUpdate]) {
        var itemDeletions: [IndexPath] = []
        var itemInsertions: [IndexPath] = []
        var itemMoves: [(IndexPath, IndexPath)] = []
        var sectionDeletions: IndexSet = []
        var sectionInsertions: IndexSet = []
        var sectionMoves: [(from: Int, to: Int)] = []
        
        diff.forEach { element in
            switch element {
            case let .deleteElement(at, section):
                itemDeletions.append((IndexPath(item: at, section: section)))
            case let .insertElement(at, section):
                itemInsertions.append((IndexPath(item: at, section: section)))
            case let .moveElement(from, to):
                itemMoves.append(((IndexPath(item: from.item, section: from.section)), (IndexPath(item: to.item, section: to.section))))
            case let .deleteSection(at):
                sectionDeletions.insert(at)
            case let .insertSection(at):
                sectionInsertions.insert(at)
            case let .moveSection(move):
                sectionMoves.append((move.from, move.to))
            }
        }
        
        self.itemInsertions = itemInsertions
        self.itemDeletions = itemDeletions
        self.itemMoves = itemMoves
        self.sectionMoves = sectionMoves
        self.sectionInsertions = sectionInsertions
        self.sectionDeletions = sectionDeletions
        
        self.itemUpdates = updates.map { $0.from.indexPath }
    }
}

// MARK: - UITableView

extension UITableView {
    
    public func registerNib(_ cellType: UITableViewCell.Type) {
        registerNib(String(describing: cellType))
    }
    
    public func registerNib(_ cellIdentifier: String, bundle: Bundle? = nil) {
        register(UINib(nibName: cellIdentifier, bundle: bundle), forCellReuseIdentifier: cellIdentifier)
    }
    
    func apply(
        batch: Batch,
        rowDeletionAnimation: UITableViewRowAnimation,
        rowInsertionAnimation: UITableViewRowAnimation,
        rowReloadAnimation: UITableViewRowAnimation,
        sectionDeletionAnimation: UITableViewRowAnimation,
        sectionInsertionAnimation: UITableViewRowAnimation
        ) {
        
        beginUpdates()
        
        if rowReloadAnimation != .none {
            reloadRows(at: batch.itemUpdates, with: rowReloadAnimation)
        }
        
        deleteRows(at: batch.itemDeletions, with: rowDeletionAnimation)
        insertRows(at: batch.itemInsertions, with: rowInsertionAnimation)
        batch.itemMoves.forEach { moveRow(at: $0.from, to: $0.to) }
        
        deleteSections(batch.sectionDeletions, with: sectionDeletionAnimation)
        insertSections(batch.sectionInsertions, with: sectionInsertionAnimation)
        batch.sectionMoves.forEach { moveSection($0.from, toSection: $0.to) }
        
        endUpdates()
    }
    
    
}

extension UITableViewCell {
    
    static var cellIdentifier: String {
        return String(describing: self)
    }
}

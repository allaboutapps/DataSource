//
//  Row.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

public protocol RowType {
    
    var identifier: String { get }
    var anyItem: Any { get }
    var diffableItem: Diffable? { get }
}

public struct Row<Item>: RowType {
    
    public let identifier: String
    public let item: Item
    
    public var anyItem: Any {
        return item
    }
    
    public var diffableItem: Diffable? {
        return item as? Diffable
    }
    
    public init(_ item: Item) {
        self.item = item
        self.identifier = String(describing: type(of: item))
    }
    
    public init(_ item: Item, identifier: String?) {
        self.item = item
        self.identifier = identifier ?? String(describing: type(of: item))
    }
    
    public func with(identifier: String) -> Row<Item> {
        return Row(item, identifier: identifier)
    }
}

public protocol LazyRowType: RowType {
    
    var anyItemClosure: () -> Any { get }
    var diffableItemClosure: (() -> Diffable)? { get }
}

public struct LazyRow<Item>: LazyRowType {
    
    public let identifier: String
    public let itemClosure: () -> Item
    public let diffableItemClosure: (() -> Diffable)?
    
    public var anyItem: Any {
        return itemClosure()
    }
    
    public var anyItemClosure: () -> Any {
        return itemClosure
    }
    
    public var diffableItem: Diffable? {
        return diffableItemClosure?()
    }
    
    public init(_ item: @escaping () -> Item, diffableItem: (() -> Diffable)? = nil) {
        self.itemClosure = item
        self.diffableItemClosure = diffableItem
        self.identifier = String(describing: Item.self)
    }
    
    public init(_ item: @escaping () -> Item, diffableItem: (() -> Diffable)? = nil, identifier: String?) {
        self.itemClosure = item
        self.diffableItemClosure = diffableItem
        self.identifier = identifier ?? String(describing: Item.self)
    }
    
    public func with(identifier: String) -> LazyRow<Item> {
        return LazyRow(itemClosure, diffableItem: diffableItemClosure, identifier: identifier)
    }
}

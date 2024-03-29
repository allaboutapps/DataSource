import Foundation

// MARK: - RowType

public protocol RowType {

    var identifier: String { get }
    var item: Any { get }
    var diffableItem: Diffable? { get }
}

// MARK: - Row

public struct Row: RowType {

    public let identifier: String
    public let item: Any

    public var diffableItem: Diffable? {
        return item as? Diffable
    }

    public init(_ item: Any, identifier: String? = nil) {
        self.identifier = identifier ?? String(describing: type(of: item))
        self.item = item
    }

    public func with(identifier: String) -> Row {
        return Row(item, identifier: identifier)
    }
}

// MARK: - LazyRowType

public protocol LazyRowType: RowType {

    var anyItemClosure: () -> Any { get }
}

// MARK: - LazyRow

public struct LazyRow<Item>: LazyRowType {

    public let identifier: String
    public let itemClosure: () -> Item

    public var item: Any {
        return itemClosure()
    }

    public var anyItemClosure: () -> Any {
        return itemClosure
    }

    public var diffableItem: Diffable? {
        return nil
    }

    public init(_ item: @escaping () -> Item, identifier: String? = nil) {
        self.identifier = identifier ?? String(describing: Item.self)
        itemClosure = item
    }

    public func with(identifier: String) -> LazyRow<Item> {
        return LazyRow(itemClosure, identifier: identifier)
    }
}

// MARK: - Extensions

public extension Array {

    func rows(_ identifier: String? = nil) -> [Row] {
        return map { Row($0, identifier: identifier) }
    }
}

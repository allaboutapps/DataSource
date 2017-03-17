//
//  Diffable.swift
//  DataSource
//
//  Created by Matthias Buchetics on 17/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

// MARK: - Diffable

public protocol Diffable {
    
    var diffIdentifier: String { get }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool
}

extension String: Diffable {
    
    public var diffIdentifier: String {
        return self
    }
    
    public func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? String else { return false }
        return self == other
    }
}

// MARK: - DiffableSection

public struct DiffableSection {
    
    let identifier: String
    let content: Any?
    let rowCount: Int
    let rowClosure: (Int) -> RowType
}

extension DiffableSection: Diffable {
    
    public var diffIdentifier: String {
        return identifier
    }
    
    public func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? DiffableSection else { return false }
        return self == other
    }
}

extension DiffableSection: Equatable {
    
    public static func ==(lhs: DiffableSection, rhs: DiffableSection) -> Bool {
        guard lhs.identifier == rhs.identifier else {
            return false
        }
        
        if lhs.content == nil && rhs.content == nil {
            return true
        }
        
        if let a = lhs.content as? Diffable,  let b = rhs.content as? Diffable {
            return a.isEqualToDiffable(b)
        }
        
        return false
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

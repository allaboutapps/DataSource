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
    var anyModel: Any { get }
    var isHidden: Bool { get }
}

public struct Row<Model>: RowType {
    
    public let identifier: String
    public let model: Model
    
    public var anyModel: Any {
        return model
    }
    
    public var isHidden: Bool {
        return false
    }
    
    public init(_ model: Model) {
        self.model = model
        self.identifier = String(describing: type(of: model))
    }
    
    public init(_ model: Model, identifier: String) {
        self.model = model
        self.identifier = identifier
    }
    
    public func with(identifier: String) -> Row<Model> {
        return Row(model, identifier: identifier)
    }
}

//
//  DataSourceDiffable.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

public protocol DataSourceDiffable {
    func isEqualToDiffable(_ other: DataSourceDiffable?) -> Bool
}

extension String: DataSourceDiffable {
    
    public func isEqualToDiffable(_ other: DataSourceDiffable?) -> Bool {
        guard let other = other as? String else { return false }
        return self == other
    }
}

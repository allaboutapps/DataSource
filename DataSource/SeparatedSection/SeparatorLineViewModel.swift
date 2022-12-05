//
//  SeparatorLineViewModel.swift
//  DataSource
//
//  Created by Michael Heinzl on 08.01.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public class SeparatorLineViewModel: Diffable {
    
    public let diffIdentifier: String
    let style: SeparatorStyle
    
    init(diffIdentifier: String, style: SeparatorStyle) {
        self.diffIdentifier = diffIdentifier
        self.style = style
    }
    
    var row: RowType {
        return Row(self)
    }
    
    public func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? SeparatorLineViewModel else { return false }
        return other.style == self.style
    }
    
}

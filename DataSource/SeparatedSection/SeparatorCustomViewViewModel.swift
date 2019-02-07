//
//  SeparatorCustomViewViewModel.swift
//  DataSource
//
//  Created by Michael Heinzl on 08.01.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class SeparatorCustomViewViewModel: Diffable {
    
    let diffIdentifier: String
    let customView: UIView
    
    init(diffIdentifier: String, customView: UIView) {
        self.diffIdentifier = diffIdentifier
        self.customView = customView
    }
    
    var row: RowType {
        return Row(self)
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        return false
    }
    
}

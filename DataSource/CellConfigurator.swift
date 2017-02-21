//
//  CellConfigurator.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public struct CellConfigurator {
    
    let rowIdentifier: String
    let cellIdentifier: String
    let configure: (RowType, UITableViewCell?) -> Void
    
    public init<Model, Cell: UITableViewCell>(rowIdentifier: String? = nil, cellIdentifier: String? = nil, configure: @escaping ((Model, Cell?) -> Void)) {
        self.rowIdentifier = rowIdentifier ?? String(describing: Model.self)
        self.cellIdentifier = cellIdentifier ?? String(describing: Cell.self)
        
        self.configure = { (row, cell) in
            guard let model = row.anyModel as? Model, let cell = cell as? Cell else {
                return
            }
            
            configure(model, cell)
        }
    }
}

//
//  TextCell.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class TextCell: UITableViewCell {
}

extension TextCell {
    
    static var configurator: CellConfigurator {
        return CellConfigurator() { (text: String, cell: TextCell, indexPath: IndexPath) in
            cell.textLabel?.text = text
        }
    }
}

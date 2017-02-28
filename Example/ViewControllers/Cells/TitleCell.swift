//
//  TitleCell.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class TitleCell: UITableViewCell {
}

extension TitleCell {
    
    func configure(text: String) {
        textLabel?.text = text
    }
    
    static var descriptor: CellDescriptor<String, TitleCell> {
        return CellDescriptor()
            .configure { (text, cell, indexPath) in
                cell.configure(text: text)
        }
    }
}

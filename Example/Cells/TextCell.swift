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
    
    func configure(text: String) {
        textLabel?.text = text
    }
}

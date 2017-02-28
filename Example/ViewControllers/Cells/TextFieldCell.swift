//
//  TextFieldCell.swift
//  DataSource
//
//  Created by Matthias Buchetics on 28/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class TextFieldCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    var field: Form.TextField!
    
    func configure(field: Form.TextField) {
        self.field = field
        
        textField.text = field.text
        textField.placeholder = field.placeholder
        textField.keyboardType = field.keyboardType
        textField.autocorrectionType = .no
    }
    
    @IBAction func textChanged(_ sender: Any) {
        field.text = textField.text
        field.changed?(field.id, field.text ?? "")
    }
}

extension TextFieldCell {
    
    static var descriptor: CellDescriptor<Form.TextField, TextFieldCell> {
        return CellDescriptor()
            .configure { (field, cell, indexPath) in
                cell.configure(field: field)
        }
    }
}

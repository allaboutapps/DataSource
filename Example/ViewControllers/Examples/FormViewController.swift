//
//  FormViewController.swift
//  DataSource
//
//  Created by Matthias Buchetics on 28/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

// MARK: - View Controller

class FormViewController: UITableViewController {

    lazy var firstNameField: Form.TextField = {
        Form.TextField(id: "firstname", placeholder: "First Name", changed: self.textFieldChanged)
    }()
    
    lazy var lastNameField: Form.TextField = {
        Form.TextField(id: "lastname", placeholder: "Last Name", changed: self.textFieldChanged)
    }()
    
    lazy var switchField: Form.SwitchField = {
        Form.SwitchField(id: "additional", title: "Show additional options", changed: self.switchFieldChanged)
    }()
    
    lazy var emailField: Form.TextField = {
        Form.TextField(id: "email", placeholder: "E-Mail", keyboardType: .emailAddress, changed: self.textFieldChanged)
    }()
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                TextFieldCell.descriptor
                    .isHidden { (field, indexPath) in
                        if field.id == self.lastNameField.id {
                            return self.firstNameField.text?.isEmpty ?? true
                        } else {
                            return false
                        }
                    },
                SwitchCell.descriptor,
                TitleCell.descriptor,
            ],
            sectionDescriptors: [
                SectionDescriptor<Void>("section-name")
                    .headerHeight { .zero },
                
                SectionDescriptor<Void>("section-additional")
                    .header {
                        .title("Additional Fields")
                    }
                    .footer {
                        .title("Here are some additional fields")
                    }
                    .isHidden {
                        !self.switchField.isOn
                    }
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.sections = [
            Section(items: [
                firstNameField,
                lastNameField,
                switchField
            ]).with(identifier: "section-name"),
            
            Section(items: [
                emailField,
                "some random text"
            ]).with(identifier: "section-additional")
        ]
        
        dataSource.reloadData(tableView, animated: false)
    }
    
    func textFieldChanged(id: String, text: String) {
        print("changed field \(id): \(text)")
        
        dataSource.reloadData(tableView, animated: true)
    }
    
    func switchFieldChanged(id: String, isOn: Bool) {
        print("changed field \(id): \(isOn)")
        
        dataSource.reloadData(tableView, animated: true)
    }
}

// MARK: - Form

protocol FormField: Diffable {
    
    var id: String { get }
}

extension FormField {
    
    var diffIdentifier: String {
        return id
    }
}

struct Form {

    class TextField: FormField {
        
        let id: String
        var text: String?
        let placeholder: String?
        let keyboardType: UIKeyboardType
        let changed: ((String, String) -> ())?
        
        init(id: String, text: String? = nil, placeholder: String? = nil, keyboardType: UIKeyboardType = .default, changed: ((String, String) -> ())? = nil) {
            self.id = id
            self.text = text
            self.placeholder = placeholder
            self.keyboardType = keyboardType
            self.changed = changed
        }
        
        func isEqualToDiffable(_ other: Diffable?) -> Bool {
            guard let other = other as? TextField else { return false }
            
            return self.id == other.id
                && self.text == other.text
                && self.placeholder == other.placeholder
                && self.keyboardType == other.keyboardType
        }
    }

    class SwitchField: FormField {
        
        let id: String
        let title: String
        var isOn: Bool
        let changed: ((String, Bool) -> ())?
        
        init(id: String, title: String, isOn: Bool = false, changed: ((String, Bool) -> ())? = nil) {
            self.id = id
            self.title = title
            self.isOn = isOn
            self.changed = changed
        }
        
        func isEqualToDiffable(_ other: Diffable?) -> Bool {
            guard let other = other as? SwitchField else { return false }
            
            return self.id == other.id
                && self.title == other.title
                && self.isOn == other.isOn
        }
    }
}



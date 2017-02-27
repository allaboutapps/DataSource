//
//  PersonCell.swift
//  Example
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

// this cell is designed in the Main.storyboard
class PersonCell: UITableViewCell {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
}

extension PersonCell {
    
    func configure(person: Person) {
        firstNameLabel?.text = person.firstName
        lastNameLabel?.text = person.lastName
    }
}

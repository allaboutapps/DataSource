//
//  Person.swift
//  Example
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

struct Person {
    
    let firstName: String
    let lastName: String
}

extension Person: CustomStringConvertible {
    
    var description: String {
        return "\(firstName) \(lastName)"
    }
}

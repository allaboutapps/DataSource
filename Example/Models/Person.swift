//
//  Person.swift
//  Example
//
//  Created by Matthias Buchetics on 24/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import DataSource

struct Person {
    
    let firstName: String
    let lastName: String
    
    func lastNameStartsWith(letters: Set<String>) -> Bool {
        let letter = lastName.substring(to: lastName.index(lastName.startIndex, offsetBy: 1))
        return letters.contains(letter)
    }
}

extension Person: Equatable {
    
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
    }
}

extension Person: DataSourceDiffable {
    
    func isEqualToDiffable(_ other: DataSourceDiffable?) -> Bool {
        guard let other = other as? Person else { return false }
        return self == other
    }
}

extension Person: CustomStringConvertible {
    
    var description: String {
        return "\(firstName) \(lastName)"
    }
}

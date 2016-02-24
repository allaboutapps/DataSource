//
//  TestExtensions.swift
//  Example
//
//  Created by Marcel Zanoni on 22/02/16.
//  Copyright © 2016 aaa - all about apps GmbH. All rights reserved.
//

import XCTest

extension XCTest {
    struct Person {
        let firstname: String
        let lastname: String
    }
    
    enum RowIdentifier: String {
        case Text
        case Person
    }
}

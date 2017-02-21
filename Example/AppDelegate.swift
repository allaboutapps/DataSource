//
//  AppDelegate.swift
//  Example
//
//  Created by Matthias Buchetics on 28/08/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        test()
        return true
    }
    
    // MARK: test
    
    func test() {
        let configurators = [
            CellConfigurator(
                configure: { (person: Person, cell: PersonCell?) in
                    cell?.textLabel?.text = person.firstName
                    print(person)
            }
            ),
            CellConfigurator(
                configure: { (text: String, cell: TextCell?) in
                    cell?.textLabel?.text = text
                    print(text)
            }
            )
        ]
        
        let dataSource = DataSource(
            sections: [
                Section(key: "Names", rows: [
                    Row(Person(firstName: "Matthias", lastName: "Buchetics")),
                    Row(Person(firstName: "Hugo", lastName: "Maier"))
                    ]),
                Section(key: "Strings", rows: [
                    Row("ABC"),
                    Row("XYZ")
                    ])
            ],
            configurators: configurators
        )
        
        let newSections: [Section<Any>] = [
            Section(key: "Strings", rows: [
                Row("ABC"),
                Row("XYZ"),
                Row("AAA"),
                ]),
            Section(key: "Names", rows: [
                Row(Person(firstName: "Matthias", lastName: "Buchetics")),
                ])
        ]
        
        let diff = dataSource.diff(sections: newSections)
        
        print(diff.elements)
    }
}


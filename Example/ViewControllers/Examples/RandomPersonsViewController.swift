//
//  RandomPersonsViewController.swift
//  DataSource
//
//  Created by Matthias Buchetics on 27/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

// MARK: - View Controller

class RandomPersonsViewController: UITableViewController {
    
    lazy var dataSource: DataSource = {
        DataSource(
            cellDescriptors: [
                PersonCell.descriptor
            ],
            sectionDescriptors: [
                SectionDescriptor<String>()
                    .header { (title, _) in
                        .title("test: " + title)
                    }
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.sections = randomData()
        dataSource.reloadData(tableView, animated: false)
    }
    
    private func randomData() -> [SectionType] {
        let count = Int.random(5, 15)
        
        let persons = (0 ..< count).map { _ in
            Person(firstName: Randoms.randomFirstName(), lastName: Randoms.randomLastName())
        }.sorted()
        
        let letters = Set(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"])
        
        let firstGroup = persons.filter {
            $0.lastNameStartsWith(letters: letters)
        }
        
        let secondGroup = persons.filter {
            !$0.lastNameStartsWith(letters: letters)
        }
        
        return [
            Section("A - L", items: firstGroup),
            Section("M - Z", items: secondGroup),
        ]
    }
    
    @IBAction func refresh(_ sender: Any) {
        dataSource.sections = randomData()
        dataSource.reloadData(tableView, animated: true)
    }
}

// MARK: - Person

struct Person {
    
    let firstName: String
    let lastName: String
    
    func lastNameStartsWith(letters: Set<String>) -> Bool {
        let letter = lastName.substring(to: lastName.index(lastName.startIndex, offsetBy: 1))
        return letters.contains(letter)
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

extension Person: Equatable {
    
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.fullName == rhs.fullName
    }
}

extension Person: Comparable {
    
    static func <(lhs: Person, rhs: Person) -> Bool {
        if lhs.lastName != rhs.lastName {
            return lhs.lastName < rhs.lastName
        } else if lhs.firstName != rhs.firstName {
            return lhs.firstName < rhs.firstName
        } else {
            return false
        }
    }
}

extension Person: Diffable {
    
    public var diffIdentifier: String {
        return fullName
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? Person else { return false }
        return self == other
    }
}

extension Person: CustomStringConvertible {
    
    var description: String {
        return fullName
    }
}

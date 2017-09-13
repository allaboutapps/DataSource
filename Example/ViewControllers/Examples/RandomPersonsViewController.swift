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
                    .didSelect { (item, indexPath) in
                        print("\(item.firstName) \(item.lastName) selected")
                        return .deselect
                }
            ],
            sectionDescriptors: [
                SectionDescriptor<String>()
                    .header { (title, _) in
                        .title(title)
                }
            ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.fallbackDelegate = self
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.sections = randomData()
        dataSource.reloadData(tableView, animated: false)
    }
    
    private func randomData() -> [SectionType] {
        let count = Int.random(5, 15)
        
        let persons = (0 ..< count).map { _ in Person.random()  }.sorted()
        
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

// MARK: - Scroll view delegate

extension RandomPersonsViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrolled: \(scrollView.contentOffset.y)")
    }
    
}

// MARK: - Person

struct Person {
    
    let firstName: String
    let lastName: String
    
    func lastNameStartsWith(letters: Set<String>) -> Bool {
        let letter = String(lastName[lastName.startIndex])
        return letters.contains(letter)
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    static func random() -> Person {
        return Person(
            firstName: Randoms.randomFirstName(),
            lastName: Randoms.randomLastName()
        )
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

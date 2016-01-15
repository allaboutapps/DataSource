# DataSource

<img src="https://img.shields.io/badge/Platform-iOS%208%2B-blue.svg" alt="Platform iOS8+">
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Language-Swift%202-orange.svg" alt="Language: Swift 2" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg" alt="Carthage compatible" /></a>

Framework to simplify the setup of `UITableView` data sources and cells. Separates the model (represented by a generic `DataSource`) from the representation (`TableViewDataSource`) by using type-safe cell configurators (`TableViewCellConfigurator`) to handle the table cell setup in an simple way.

`DataSource` is not limited to table views but could be extended to collection views or other custom representations as well.

## Requirements

iOS 8.0+, Swift 2

## Usage

An example app is included demonstrating DataSource's functionality. The example demonstrates various uses cases ranging from a simple list of strings to more complex examples with heterogenous section types.

### Getting Started

Create a `DataSource` with a single section and some rows that all share the same row identifier:

    let dataSource = DataSource([
        Section(rowIdentifier: Identifiers.TextCell.rawValue, rows: ["a", "b", "c", "d"])
    ])

Create a `TableViewDataSource` with a single `TableViewCellConfigurator` for the strings:

    let tableDataSource = TableViewDataSource(
        dataSource: dataSource1,
        configurator: TableViewCellConfigurator(Identifiers.TextCell.rawValue) { (title: String, cell: UITableViewCell, indexPath: NSIndexPath) in
            cell.textLabel?.text = "\(indexPath.row): \(title)"
        })

Assign it to your tableView´s dataSource:

    tableView.dataSource = tableDataSource

Note: Make sure to keep a strong reference to `tableDataSource` (e.g. by storing it in a property).

### Multiple Sections and Row Types

Create a `DataSource` with multiple sections and rows:

    let dataSource = DataSource([
        Section(title: "B", rowIdentifier: Identifiers.PersonCell.rawValue, rows: [
            Person(firstName: "Matthias", lastName: "Buchetics"),
            ]),
        Section(title: "M", rowIdentifier: Identifiers.PersonCell.rawValue, rows: [
            Person(firstName: "Hugo", lastName: "Maier"),
            Person(firstName: "Max", lastName: "Mustermann"),
            ]),
        Section(title: "Strings", rowIdentifier: Identifiers.TextCell.rawValue, rows: [
            "some text",
            "another text"
            ]),
        Section(rowIdentifier: Identifiers.ButtonCell.rawValue, rows: [
            Button.Add,
            Button.Remove
            ]),
        ])

Create a `TableViewDataSource` with a `TableViewCellConfigurator` for each row type:

    let tableDataSource = TableViewDataSource(
        dataSource: dataSource,
        configurators: [
            TableViewCellConfigurator(Identifiers.PersonCell.rawValue) { (person: Person, cell: PersonCell, _) in
                cell.firstNameLabel?.text = person.firstName
                cell.lastNameLabel?.text = person.lastName
            },
            TableViewCellConfigurator(Identifiers.TextCell.rawValue) { (title: String, cell: UITableViewCell, _) in
                cell.textLabel?.text = title
            },
            TableViewCellConfigurator(Identifiers.ButtonCell.rawValue) { (button: Button, cell: ButtonCell, _) in
                switch (button) {
                case .Add:
                    cell.titleLabel?.text = "Add"
                    cell.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.2, alpha: 0.8)
                case .Remove:
                    cell.titleLabel?.text = "Remove"
                    cell.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
                }
            },
        ])

Assign it to your tableView´s dataSource and again make sure to keep a strong reference to the data source.

### Creating rows using a creator closure

Instead of setting an array of rows you can also instantiate rows using a closure:

    let dataSource = DataSource([
        Section(title: "test", rowCountClosure: { return 5 }, rowCreatorClosure: { (rowIndex) in
            return Row(identifier: Identifiers.TextCell.rawValue, data: ((rowIndex + 1) % 2 == 0) ? "even" : "odd")
        }),
        Section<Any>(title: "mixed", rowCountClosure: { return 5 }, rowCreatorClosure: { (rowIndex) in
            if rowIndex % 2 == 0 {
                return Row(identifier: Identifiers.TextCell.rawValue, data: "test")
            }
            else {
               return Row(identifier: Identifiers.PersonCell.rawValue, data: Person(firstName: "Max", lastName: "Mustermann"))
            }
        })
        ])

Create a `TableViewDataSource` with cell configurators as shown above.

### Convenience

Several extensions on `Array` and `Dictionary` exist to make creating data sources even easier.

Create a data source with a single section based on an array:

    let dataSource = ["a", "b", "c", "d"].toDataSource(Identifiers.TextCell.rawValue)

Create a data source based on an dictionary, using it's keys as the section titles:

    let data = [
        "section 1": ["a", "b", "c"],
        "section 2": ["d", "e", "f"],
        "section 3": ["g", "h", "i"],
    ]
    
    let dataSource = data.toDataSource(Identifiers.TextCell.rawValue, orderedKeys: data.keys.sort())

Note: Because dictionaries are unordered, it's required to provide an array of ordered keys as well.

## Installation

### Carthage

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
git "ssh://git@git.allaboutapps.at:2222/aaaios/datasource.git"
```

Then run `carthage update`.

### Manually

Just drag and drop the `.swift` files in the `DataSource` folder into your project.

## License

`DataSource` is available under the MIT license. See the [LICENSE](https://github.com/mbuchetics/DataSource/blob/master/LICENSE.md) file for more info.

## Contact

TODO

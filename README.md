# DataSource

[![Swift 4](https://img.shields.io/badge/Language-Swift%204-orange.svg)](https://developer.apple.com/swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/MBDataSource.svg)](https://cocoapods.org/pods/MBDataSource)

Framework to simplify the setup and configuration of `UITableView` data sources and cells. It allows a type-safe setup of `UITableViewDataSource` and (optionally) `UITableViewDelegate`. `DataSource` also provides out-of-the-box diffing and animated deletions, inserts, moves and changes.

## Usage

An example app is included demonstrating DataSource's functionality. The example demonstrates various uses cases ranging from a simple list of strings to more complex uses cases such as setting up a dynamic form.

### Getting Started

Create a `DataSource` with a `CellDescriptor` that describes how the `UITableViewCell` (in this case a `TitleCell`) is configured using a data model (`Example`).
Additionally, we also add a handler for `didSelect` which handles the `didSelectRowAtIndexPath` method of `UITableViewDelegate`.

```swift
let dataSource: DataSource = {
    DataSource(
        cellDescriptors: [
            CellDescriptor<Example, TitleCell>()
                .configure { (example, cell, indexPath) in
                    cell.textLabel?.text = example.title
                    cell.accessoryType = .disclosureIndicator
                }
                .didSelect { (example, indexPath) in
                    self.performSegue(withIdentifier: example.segue, sender: nil)
                    return .deselect
                }
            ])
    }()
)
```

Next, setup your `dataSource` as the `dataSource` and `delegate` of `UITableView`.

```swift
tableView.dataSource = dataSource
tableView.delegate = dataSource
```

Next, create and set the models. Don't forget to call `reloadData`.

```swift
dataSource.sections = [
    Section(items: [
        Example(title: "Random Persons", segue: "showRandomPersons"),
        Example(title: "Form", segue: "showForm"),
        Example(title: "Lazy Rows", segue: "showLazyRows"),
        Example(title: "Diff & Update", segue: "showDiff"),
    ])
]

dataSource.reloadData(tableView, animated: false)
```

### Sections

`DataSource` can also be used to configure section headers and footers. Similar to `CellDescriptors` you can define one or more `SectionDescriptors`:

```swift
let dataSource: DataSource = {
    DataSource(
        cellDescriptors: [
            CellDescriptor()
                .configure { (person, cell, indexPath) in
                    cell.configure(person: person)
                }
        ],
        sectionDescriptors: [
            SectionDescriptor<String>()
                .header { (title, _) in
                    .title(title)
                }
        ])
}()
```

Sections headers and footers can have custom views (`.view(...)`) or simple titles (`.title(...)`). Delegate methods such as `heightForHeaderInSection` are supported as well (`headerHeight`).

### Diffing

Diffing and animated changes between two sets of data are supported if your data models implement the `Diffable` protocol.

```swift
public protocol Diffable {    
    var diffIdentifier: String { get }    
    func isEqualToDiffable(_ other: Diffable?) -> Bool
}
```

`diffIdentifier` is a `String` identifier which describes whether the identity of two models is different. Think of it as a primary key in a database. Different `diffIdentifiers` will lead to an animated insert, delete or move change. Additionally, `isEqualToDiffable` can be used to describe whether the data or content of a models has changed even if the `diffIdentifier` is the same. For example, if the name of a person was changed in a database, the primarykey of that person would usually remain the same. In such cases you usually don't want an insert, delete or move but instead and (potentially animated) update of the corresponding row in your table.

Diffing is demonstrated by two examples:

`RandomPersonsViewController` creates a random set of persons in two sections and animates the changes between the datasets.

```swift
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
```

`DiffViewController` creates rows of numbers where the `diffIdentifier` is the number itself and the content is the name of that number in English or German. This shows how the animated row changes can be accomplished.

```swift
struct DiffItem {    
    let value: Int
    let text: String
    let diffIdentifier: String

    init(_ value: Int, text: String) {
        self.value = value
        self.text = text
        self.diffIdentifier = String(value)
    }
}

extension DiffItem: Diffable {    
    public func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? DiffItem else { return false }
        return self.text == other.text
    }
}
```

Please refer to the examples for the full code.

### Hiding Rows and Sections

Both, `CellDescriptor` and `SectionDescriptor` provide an `isHidden` closure, which allow to simply hide and show rows based on any custom criteria.

The `FormViewController` example uses this to only show the last name field whenever the first name is not empty, and also shows an "additional fields" section whenever a switch is enabled:

```swift
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
                .isHidden {
                    !self.switchField.isOn
                }
        ])
    }()
```

The `isHidden` closure is evaluated whenever `dataSource.reloadData(...)` is called.

### Delegates and Fallbacks

`DataSource` provides a convenient way to handle all `UITableViewDelegate` methods in a type-safe and simple way using closures. In most cases you define those closures on the `CellDescriptor` or `SectionDescriptor`. However, sometimes this leads to duplicated code if, for example, you have different cells but the code executed for a selection is the same. In these cases you can set the delegate closures on the `DataSource` itself:

```swift
dataSource.didSelect = { (row, indexPath) in
    print("selected")
    return .deselect
}
```

These closures will be used as a fallback if no closure for the specific delegate method is defined on `CellDescriptor` (or `SectionDescriptor`).

Additionally, you can set a fallback `UITableViewDelegate` and `UITableViewDataSource`, which are again used if the matching closure on `CellDescriptor` or `SectionDescriptor` is not set.

```swift
dataSource.fallbackDelegate = self
dataSource.fallbackDataSource = self
```

Using these fallback mechanisms you can choose which parts of `DataSource` you want to use in your specific use case. For example, you could use it to setup and configure all your cells, animate changes between datasets but keep your existing `UITableViewDelegate` code.

The `fallbackDelegate` can be used to implement methods that don't belong to `DataSource`, like e.g. `UIScrollViewDelegate` methods. You should take extra care that the fallback delegate  needs to be set *before* setting the table view delegate, otherwise certain delegate methods will never be called by `UIKit`.

```swift
// Always set the fallback before setting the table view delegate
dataSource.fallbackDelegate = self
tableView.dataSource = dataSource
tableView.delegate = dataSource
```

### Custom bundles

Cells can be registered from custom bundles. You can specify in the cell descriptor from which bundle the cell should be loaded. The bundle defaults to the main bundle.

```swift
let descriptor = CellDescriptor(bundle: customBundle)
```

## Version Compatibility

Current Swift compatibility breakdown:

| Swift Version | Framework Version |
| ------------- | ----------------- |
| 4.x           | 5.x               |
| 3.x           | 3.x, 4.x          |

[all releases]: https://github.com/mbuchetics/DataSource/releases

## Installation

### Carthage

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "mbuchetics/DataSource", ~> 5.0
```

Then run `carthage update`.

### CocoaPods

For DataSource, use the following entry in your Podfile:

```rb
pod 'MBDataSource'
```

Then run `pod install`.

In any file you'd like to use DataSource in, don't forget to import the framework with `import DataSource`.

### Manually

Just drag and drop the `.swift` files in the `DataSource` folder into your project.

## Contributing

* Create something awesome, make the code better, add some functionality,
  whatever (this is the hardest part).
* [Fork it](http://help.github.com/forking/)
* Create new branch to make your changes
* Commit all your changes to your branch
* Submit a [pull request](http://help.github.com/pull-requests/)

## Contact

Contact me at [matthias.buchetics.com](http://matthias.buchetics.com) or follow me on [Twitter](https://twitter.com/mbuchetics).

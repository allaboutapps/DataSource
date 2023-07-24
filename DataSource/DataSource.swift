import Differ
import UIKit

public class DataSource: NSObject {
    public var sections: [SectionType] = []
    public internal(set) var visibleSections: [SectionType] = []

    // MARK: UITableViewDataSource

    public var configure: ((RowType, UITableViewCell, IndexPath) -> Void)?
    public var canEdit: ((RowType, IndexPath) -> Bool)?
    public var canMove: ((RowType, IndexPath) -> Bool)?
    public var sectionIndexTitles: (() -> [String]?)?
    public var sectionForSectionIndex: ((String, Int) -> Int)?
    public var commitEditing: ((RowType, UITableViewCell.EditingStyle, IndexPath) -> Void)?
    public var moveRow: ((RowType, (IndexPath, IndexPath)) -> Void)?

    public var fallbackDataSource: UITableViewDataSource?

    // MARK: UITableViewDelegate

    public var height: ((RowType, IndexPath) -> CGFloat)?

    // no RowType parameter for estimatedHeight because we do not want to potentially instantiate
    // a LazyRow just to get the height estimate
    public var estimatedHeight: ((IndexPath) -> CGFloat)?

    public var shouldHighlight: ((RowType, IndexPath) -> Bool)?
    public var didHighlight: ((RowType, IndexPath) -> Void)?
    public var didUnhighlight: ((RowType, IndexPath) -> Void)?

    public var willSelect: ((RowType, IndexPath) -> IndexPath?)?
    public var willDeselect: ((RowType, IndexPath) -> IndexPath?)?
    public var didSelect: ((RowType, IndexPath) -> SelectionResult)?
    public var didDeselect: ((RowType, IndexPath) -> Void)?

    public var willDisplay: ((RowType, UITableViewCell, IndexPath) -> Void)?
    public var didEndDisplaying: ((UITableViewCell, IndexPath) -> Void)?

    public var editingStyle: ((RowType, IndexPath) -> UITableViewCell.EditingStyle)?
    public var titleForDeleteConfirmationButton: ((RowType, IndexPath) -> String?)?
    public var editActions: ((RowType, IndexPath) -> [UITableViewRowAction]?)?
    public var shouldIndentWhileEditing: ((RowType, IndexPath) -> Bool)?
    public var willBeginEditing: ((RowType, IndexPath) -> Void)?
    public var didEndEditing: ((IndexPath?) -> Void)?

    public var sectionHeader: ((SectionType, Int) -> HeaderFooter)?
    public var sectionFooter: ((SectionType, Int) -> HeaderFooter)?

    public var sectionHeaderHeight: ((SectionType, Int) -> SectionHeight)?
    public var sectionFooterHeight: ((SectionType, Int) -> SectionHeight)?

    public var willDisplaySectionHeader: ((SectionType, UIView, Int) -> Void)?
    public var willDisplaySectionFooter: ((SectionType, UIView, Int) -> Void)?

    public var didEndDisplayingSectionHeader: ((UIView, Int) -> Void)?
    public var didEndDisplayingSectionFooter: ((UIView, Int) -> Void)?

    public var targetIndexPathForMove: ((RowType, (IndexPath, IndexPath)) -> IndexPath)?
    public var indentationLevel: ((RowType, IndexPath) -> Int)?
    public var shouldShowMenu: ((RowType, IndexPath) -> Bool)?
    public var canPerformAction: ((RowType, Selector, Any?, IndexPath) -> Bool)?
    public var performAction: ((RowType, Selector, Any?, IndexPath) -> Void)?
    public var canFocus: ((RowType, IndexPath) -> Bool)?

    // MARK: Swipe Actions (iOS 11+ only)

    private var _leadingSwipeActions: ((RowType, IndexPath) -> Any?)?
    private var _trailingSwipeActions: ((RowType, IndexPath) -> Any?)?

    public var _configurationForMenuAtLocationClosure: ((RowType, IndexPath) -> Any)?

    // MARK: UITableViewDataSourcePrefetching

    public var prefetchRows: (([IndexPath]) -> Void)?
    public var cancelPrefetching: (([IndexPath]) -> Void)?

    public weak var fallbackDataSourcePrefetching: UITableViewDataSourcePrefetching?

    // MARK: Fallback delegate

    /// Fallback used when DataSource doesn't handle delegate method itself.
    /// - Note: The fallback delegate needs to be set *before* setting the table view's delegate, otherwise certain delegate methods will never be called.
    public weak var fallbackDelegate: UITableViewDelegate?

    override public func forwardingTarget(for _: Selector!) -> Any? {
        return fallbackDelegate
    }

    override public func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            if #available(iOS 11.0, *) {
                switch aSelector {
                case #selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)):
                    return isLeadingSwipeActionsImplemented ? true : fallbackDelegateResponds(to: aSelector)
                case #selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)):
                    return isTrailingSwipeActionsImplemented ? true : fallbackDelegateResponds(to: aSelector)
                default:
                    return true
                }
            } else {
                return true
            }
        }

        return fallbackDelegateResponds(to: aSelector)
    }

    private func fallbackDelegateResponds(to aSelector: Selector!) -> Bool {
        let result = fallbackDelegate?.responds(to: aSelector) ?? false
        return result
    }

    @available(iOS 11.0, *)
    private var isLeadingSwipeActionsImplemented: Bool {
        if _leadingSwipeActions != nil {
            return true
        }

        return cellDescriptors.values.contains(where: { ($0 as? CellDescriptorTypeiOS11)?.leadingSwipeActionsClosure != nil })
    }

    @available(iOS 11.0, *)
    private var isTrailingSwipeActionsImplemented: Bool {
        if _trailingSwipeActions != nil {
            return true
        }

        return cellDescriptors.values.contains(where: { ($0 as? CellDescriptorTypeiOS11)?.trailingSwipeActionsClosure != nil })
    }

    // MARK: ContextMenu

    // MARK: Additional

    public var isRowHidden: ((RowType, IndexPath) -> Bool)?
    public var isSectionHidden: ((SectionType, Int) -> Bool)?
    public var update: ((RowType, UITableViewCell, IndexPath) -> Void)?

    // MARK: Internal

    var cellDescriptors: [String: CellDescriptorType] = [:]
    var sectionDescriptors: [String: SectionDescriptorType] = [:]

    var reuseIdentifiers: Set<String> = []
    let registerNibs: Bool

    // MARK: Init

    public init(cellDescriptors: [CellDescriptorType], sectionDescriptors: [SectionDescriptorType] = [], registerNibs: Bool = true) {
        self.registerNibs = registerNibs
        super.init()

        for d in cellDescriptors {
            self.cellDescriptors[d.rowIdentifier] = d
        }

        addDescriptorIfNotSet(SeparatorLineCell.descriptorLine)
        addDescriptorIfNotSet(SeparatorLineCell.descriptorCustomView)

        let defaultSectionDescriptors: [SectionDescriptorType] = [
            SectionDescriptor<Void>(),
            SectionDescriptor<String>()
                .header { title, _ in
                    .title(title)
                },
        ]

        for d in defaultSectionDescriptors {
            self.sectionDescriptors[d.identifier] = d
        }

        for d in sectionDescriptors {
            self.sectionDescriptors[d.identifier] = d
        }
    }

    private func addDescriptorIfNotSet(_ descriptor: CellDescriptorType) {
        if cellDescriptors[descriptor.rowIdentifier] == nil {
            cellDescriptors[descriptor.rowIdentifier] = descriptor
        }
    }

    // MARK: Getters & Setters

    public func section(at index: Int) -> SectionType? {
        guard sections.count > index else {
            return nil
        }
        
        return sections[index]
    }

    public func row(at indexPath: IndexPath) -> RowType? {
        guard sections.count > indexPath.section else {
            return nil
        }
        
        let section = sections[indexPath.section]
        
        guard section.numberOfRows > indexPath.row else {
            return nil
        }
        
        return section.row(at: indexPath.row)
    }

    public func visibleSection(at index: Int) -> SectionType? {
        guard visibleSections.count > index else {
            return nil
        }
        
        return visibleSections[index]
    }

    public func visibleRow(at indexPath: IndexPath) -> RowType? {
        guard visibleSections.count > indexPath.section else {
            return nil
        }
        
        let visibleSection = visibleSections[indexPath.section]
        
        guard visibleSection.numberOfVisibleRows > indexPath.row else {
            return nil
        }
        
        return visibleSection.visibleRow(at: indexPath.row)
    }

    // MARK: Cell Descriptors

    public func cellDescriptor(at indexPath: IndexPath) -> CellDescriptorType? {
        guard let row = visibleRow(at: indexPath) else {
            return nil
        }

        return cellDescriptors[row.identifier]
    }

    public func cellDescriptor(for rowIdentifier: String) -> CellDescriptorType? {
        cellDescriptors[rowIdentifier]
    }

    // MARK: Section Descriptors

    public func sectionDescriptor(at index: Int) -> SectionDescriptorType? {
        guard let section = visibleSection(at: index) else {
            return nil
        }

        if let sectionDescriptor = sectionDescriptors[section.identifier] {
            return sectionDescriptor
        } else {
            print("[DataSource] no sectionDescriptor found for section \(index)")
            return nil
        }
    }

    public func sectionDescriptor(for identifier: String) -> SectionDescriptorType? {
        if let sectionDescriptor = sectionDescriptors[identifier] {
            return sectionDescriptor
        } else {
            print("[DataSource] no sectionDescriptor found for sectionIdentifier \(identifier)")
            return nil
        }
    }

    // MARK: Visibility

    internal func updateVisibility() {
        visibleSections = updateSectionVisiblity()
    }

    internal func updateSectionVisiblity() -> [SectionType] {
        var visibleSections = [SectionType]()

        for (index, section) in sections.enumerated() {
            section.updateVisibility(sectionIndex: index, dataSource: self)

            let sectionDescriptor = self.sectionDescriptor(for: section.identifier)
            let isHidden: Bool

            if let closure = sectionDescriptor?.isHiddenClosure ?? isSectionHidden {
                isHidden = closure(section, index)
            } else {
                isHidden = false
            }

            if isHidden == false, section.numberOfVisibleRows > 0 {
                visibleSections.append(section)
            }
        }

        return visibleSections
    }

    // MARK: Reload Data

    public func reloadData(_ tableView: UITableView, animated: Bool) {
        if tableView.dataSource == nil {
            tableView.dataSource = self
        }

        if tableView.delegate == nil {
            tableView.delegate = self
        }

        if animated {
            reloadDataAnimated(tableView)
        } else {
            visibleSections = updateSectionVisiblity()
            tableView.reloadData()
        }
    }

    public func reloadDataAnimated(
        _ tableView: UITableView,
        rowDeletionAnimation: UITableView.RowAnimation = .fade,
        rowInsertionAnimation: UITableView.RowAnimation = .fade,
        rowReloadAnimation: UITableView.RowAnimation = .none,
        sectionDeletionAnimation: UITableView.RowAnimation = .fade,
        sectionInsertionAnimation: UITableView.RowAnimation = .fade
    ) {
        let oldSections = visibleSections.map { $0.diffableSection }
        let newSections = updateSectionVisiblity()
        let diffableNewSections = newSections.map { $0.diffableSection }

        let diff = computeDiff(oldSections: oldSections, newSections: diffableNewSections)
        let updates = computeUpdate(oldSections: oldSections, newSections: diffableNewSections)

        visibleSections = newSections

        if rowReloadAnimation == .none {
            for update in updates {
                updateRow(tableView, row: update.to.row, at: update.from.indexPath)
            }
        }

        tableView.apply(
            batch: Batch(diff: diff, updates: updates),
            rowDeletionAnimation: rowDeletionAnimation,
            rowInsertionAnimation: rowInsertionAnimation,
            rowReloadAnimation: rowReloadAnimation,
            sectionDeletionAnimation: sectionDeletionAnimation,
            sectionInsertionAnimation: sectionInsertionAnimation
        )
    }

    public func updateRow(_ tableView: UITableView, row: RowType, at indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(for: row.identifier)

        let updateClosure = cellDescriptor?.updateClosure ?? update
        let configureClosure = cellDescriptor?.configureClosure ?? configure

        let closure = updateClosure ?? configureClosure

        if let cell = tableView.cellForRow(at: indexPath), let closure = closure {
            closure(row, cell, indexPath)
        }
    }
}

@available(iOS 11,*)
public extension DataSource {
    var leadingSwipeActions: ((RowType, IndexPath) -> UISwipeActionsConfiguration?)? {
        get {
            if _leadingSwipeActions == nil {
                return nil
            }

            return { [weak self] rowType, indexPath in
                self?._leadingSwipeActions?(rowType, indexPath) as? UISwipeActionsConfiguration
            }
        }
        set {
            _leadingSwipeActions = newValue
        }
    }

    var trailingSwipeActions: ((RowType, IndexPath) -> UISwipeActionsConfiguration?)? {
        get {
            if _trailingSwipeActions == nil {
                return nil
            }

            return { [weak self] rowType, indexPath in
                self?._trailingSwipeActions?(rowType, indexPath) as? UISwipeActionsConfiguration
            }
        }
        set {
            _trailingSwipeActions = newValue
        }
    }
}

@available(iOS 13,*)
public extension DataSource {
    var configurationForMenuAtLocationClosure: ((RowType, IndexPath) -> UIContextMenuConfiguration?)? {
        get {
            if _configurationForMenuAtLocationClosure == nil {
                return nil
            }

            return { [weak self] rowType, indexPath in
                self?._configurationForMenuAtLocationClosure?(rowType, indexPath) as? UIContextMenuConfiguration
            }
        }

        set {
            _configurationForMenuAtLocationClosure = newValue
        }
    }
}

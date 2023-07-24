import Differ
import UIKit

extension DataSource: UITableViewDataSource {

    // MARK: Counts

    public func numberOfSections(in _: UITableView) -> Int {
        return visibleSections.count
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleSections[section].numberOfVisibleRows
    }

    // MARK: Configuration

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellDescriptor = cellDescriptor(at: indexPath) else {
            fatalError("[DataSource] no cellDescriptor found for indexPath \(indexPath) with identifier \(visibleRow(at: indexPath)?.identifier)")
        }

        let cellIdentifier = cellDescriptor.cellIdentifier
        let bundle = cellDescriptor.bundle ?? Bundle.main

        if registerNibs, !reuseIdentifiers.contains(cellIdentifier) {
            if bundle.path(forResource: cellIdentifier, ofType: "nib") != nil {
                tableView.registerNib(cellIdentifier, bundle: bundle)
                reuseIdentifiers.insert(cellIdentifier)
            } else if cellDescriptor.cellClass is AutoRegisterCell.Type {
                tableView.register(cellDescriptor.cellClass, forCellReuseIdentifier: cellIdentifier)
                reuseIdentifiers.insert(cellIdentifier)
            }
        }

        if let closure = cellDescriptor.configureClosure ?? configure {
            guard let row = visibleRow(at: indexPath) else {
                fatalError("[DataSource] no visible row found for indexPath \(indexPath)")
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

            closure(row, cell, indexPath)

            return cell
        } else if let fallbackDataSource = fallbackDataSource {
            return fallbackDataSource.tableView(tableView, cellForRowAt: indexPath)
        } else {
            fatalError("[DataSource] no configure closure and no fallback UITableViewDataSource set")
        }
    }

    // MARK: Header & Footer

    public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.headerClosure ?? sectionHeader {
            guard let visibleSection = visibleSection(at: section) else {
                return nil
            }

            let header = closure(visibleSection, section)

            switch header {
            case .title(let title):
                return title
            default:
                return nil
            }
        }

        return nil
    }

    public func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.footerClosure ?? sectionFooter {
            guard let visibleSection = visibleSection(at: section) else {
                return nil
            }

            let footer = closure(visibleSection, section)

            switch footer {
            case .title(let title):
                return title
            default:
                return nil
            }
        }

        return nil
    }

    // MARK: Editing

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        guard let visibleRow = visibleRow(at: indexPath) else {
            return false
        }

        if let closure = cellDescriptor?.canEditClosure ?? canEdit {
            return closure(visibleRow, indexPath)
        }

        return fallbackDataSource?.tableView?(tableView, canEditRowAt: indexPath)
            ?? false
    }

    // MARK: Moving & Reordering

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.canMoveClosure ?? canMove {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return false
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDataSource?.tableView?(tableView, canMoveRowAt: indexPath)
            ?? false
    }

    // MARK: Index

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles?()
            ?? fallbackDataSource?.sectionIndexTitles?(for: tableView)
    }

    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionForSectionIndex?(title, index)
            ?? fallbackDataSource?.tableView?(tableView, sectionForSectionIndexTitle: title, at: index)
            ?? index
    }

    // MARK: Data manipulation

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.commitEditingClosure ?? commitEditing {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return
            }
            
            closure(visibleRow, editingStyle, indexPath)
            return
        }

        fallbackDataSource?.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: sourceIndexPath)

        if let closure = cellDescriptor?.moveRowClosure ?? moveRow {
            guard let visibleRow = visibleRow(at: sourceIndexPath) else {
                return
            }
            
            closure(visibleRow, (sourceIndexPath, destinationIndexPath))
            return
        }

        fallbackDataSource?.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
    }
}

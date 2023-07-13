import Differ
import UIKit

extension DataSource: UITableViewDelegate {
    // MARK: Highlighting

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.shouldHighlightClosure ?? shouldHighlight {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return false
            }

            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, shouldHighlightRowAt: indexPath)
            ?? true
    }

    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.didHighlightClosure ?? didHighlight {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return
            }

            closure(visibleRow, indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, didHighlightRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.didUnhighlightClosure ?? didUnhighlight {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return
            }

            closure(visibleRow, indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, didUnhighlightRowAt: indexPath)
    }

    // MARK: Selection

    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.willSelectClosure ?? willSelect {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return indexPath
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, willSelectRowAt: indexPath)
            ?? indexPath
    }

    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.willDeselectClosure ?? willDeselect {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return indexPath
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, willDeselectRowAt: indexPath)
            ?? indexPath
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.didSelectClosure ?? didSelect {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return
            }
            
            let selectionResult = closure(visibleRow, indexPath)

            switch selectionResult {
            case .deselect:
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            default:
                break
            }
        } else {
            fallbackDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.didDeselectClosure ?? didDeselect {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return
            }
            
            closure(visibleRow, indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, didDeselectRowAt: indexPath)
    }

    // MARK: Header & Footer

    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.headerClosure ?? sectionHeader {
            guard let visibleSection = visibleSection(at: section) else {
                return nil
            }
            
            let header = closure(visibleSection, section)

            switch header {
            case .view(let view):
                return view
            default:
                return nil
            }
        }

        return nil
    }

    public func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.footerClosure ?? sectionFooter {
            guard let visibleSection = visibleSection(at: section) else {
                return nil
            }
            
            let footer = closure(visibleSection, section)

            switch footer {
            case .view(let view):
                return view
            default:
                return nil
            }
        }

        return nil
    }

    // MARK: Height

    // NOTE: estimated section header and footer heights are not supported

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.heightClosure ?? height {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return tableView.rowHeight
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, heightForRowAt: indexPath)
            ?? tableView.rowHeight
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.section
        let section = visibleSection(at: index)

        // Do not get the CellDescriptor if we are dealing with a LazySection because it would instantiate all the rows,
        // i.e. estimatedHeightClosure will not be called for LazySections. Instead, use the estimatedHeight on the
        // DataSource, the fallback delegate or a constant.

        if !(section is LazySectionType) {
            let cellDescriptor = self.cellDescriptor(at: indexPath)

            if let closure = cellDescriptor?.estimatedHeightClosure {
                guard let visibleRow = visibleRow(at: indexPath) else {
                    return UITableView.automaticDimension
                }
                
                return closure(visibleRow, indexPath)
            }
        }

        if let closure = estimatedHeight {
            return closure(indexPath)
        }

        if let result = fallbackDelegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) {
            return result
        }

        if tableView.estimatedRowHeight > 0 {
            return tableView.estimatedRowHeight
        }

        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.headerHeightClosure ?? sectionHeaderHeight {
            guard let visibleSection = visibleSection(at: section) else {
                return UITableView.automaticDimension
            }
            
            return closure(visibleSection, section).floatValue(for: tableView.style)
        }

        if let result = fallbackDelegate?.tableView?(tableView, heightForHeaderInSection: section) {
            return result
        }

        if let headerClosure = sectionDescriptor?.headerClosure ?? sectionHeader {
            guard let visibleSection = visibleSection(at: section) else {
                return 0.0
            }
            
            let header = headerClosure(visibleSection, section)

            switch header {
            case .title:
                return UITableView.automaticDimension
            case .view(let view):
                let height = view.bounds.height

                if height == 0 {
                    return tableView.sectionHeaderHeight > 0 ? tableView.sectionHeaderHeight : UITableView.automaticDimension
                } else {
                    return height
                }
            default:
                return 0.0
            }
        }

        return 0.0
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.footerHeightClosure ?? sectionFooterHeight {
            guard let visibleSection = visibleSection(at: section) else {
                return UITableView.automaticDimension
            }
            
            return closure(visibleSection, section).floatValue(for: tableView.style)
        }

        if let result = fallbackDelegate?.tableView?(tableView, heightForFooterInSection: section) {
            return result
        }

        if let footerClosure = sectionDescriptor?.footerClosure ?? sectionFooter {
            guard let visibleSection = visibleSection(at: section) else {
                return 0.0
            }
            
            let footer = footerClosure(visibleSection, section)

            switch footer {
            case .title:
                return UITableView.automaticDimension
            case .view(let view):
                let height = view.bounds.height

                if height == 0 {
                    return tableView.sectionFooterHeight > 0 ? tableView.sectionFooterHeight : UITableView.automaticDimension
                } else {
                    return height
                }
            default:
                return 0.0
            }
        }

        return 0.0
    }

    // MARK: Display customization

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.willDisplayClosure ?? willDisplay {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return
            }
            
            closure(visibleRow, cell, indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.willDisplayHeaderClosure ?? willDisplaySectionHeader {
            guard let visibleSection = visibleSection(at: section) else {
                return
            }
            
            closure(visibleSection, view, section)
            return
        }

        fallbackDelegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.willDisplayFooterClosure ?? willDisplaySectionFooter {
            guard let visibleSection = visibleSection(at: section) else {
                return
            }
            
            closure(visibleSection, view, section)
            return
        }

        fallbackDelegate?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }

    // the didEnd delegate methods are only supported on a "fallback" level as we may not have the row or section
    // available at this point anymore and we don't want to keep a reference to old data

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let closure = didEndDisplaying {
            closure(cell, indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let closure = didEndDisplayingSectionHeader {
            closure(view, section)
            return
        }

        fallbackDelegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if let closure = didEndDisplayingSectionFooter {
            closure(view, section)
            return
        }

        fallbackDelegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }

    // MARK: Editing

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.editingStyleClosure ?? editingStyle {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return .none
            }
            
            return closure(visibleRow, indexPath)
        }

        if let result = fallbackDelegate?.tableView?(tableView, editingStyleForRowAt: indexPath) {
            return result
        }

        if self.tableView(tableView, canEditRowAt: indexPath) {
            return .delete
        }

        return .none
    }

    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.titleForDeleteConfirmationButtonClosure ?? titleForDeleteConfirmationButton {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return nil
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.editActionsClosure ?? editActions {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return nil
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, editActionsForRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.shouldIndentWhileEditingClosure ?? shouldIndentWhileEditing {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return true
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, shouldIndentWhileEditingRowAt: indexPath)
            ?? true
    }

    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.willBeginEditingClosure ?? willBeginEditing {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return
            }
            
            closure(visibleRow, indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, willBeginEditingRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let closure = didEndEditing {
            closure(indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, didEndEditingRowAt: indexPath)
    }

    // MARK: Moving & Reordering

    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let cellDescriptor = self.cellDescriptor(at: sourceIndexPath)

        if let closure = cellDescriptor?.targetIndexPathForMoveClosure ?? targetIndexPathForMove {
            guard let visibleRow = visibleRow(at: sourceIndexPath) else {
                return proposedDestinationIndexPath
            }
            
            return closure(visibleRow, (sourceIndexPath, proposedDestinationIndexPath))
        }

        return fallbackDelegate?.tableView?(tableView, targetIndexPathForMoveFromRowAt: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
            ?? proposedDestinationIndexPath
    }

    // MARK: Indentation

    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.indentationLevelClosure ?? indentationLevel {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return 0
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, indentationLevelForRowAt: indexPath)
            ?? 0
    }

    // MARK: Copy & Paste

    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.shouldShowMenuClosure ?? shouldShowMenu {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return false
            }
            
            return closure(visibleRow, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, shouldShowMenuForRowAt: indexPath)
            ?? false
    }

    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.canPerformActionClosure ?? canPerformAction {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return false
            }
            
            return closure(visibleRow, action, sender, indexPath)
        }

        return fallbackDelegate?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender)
            ?? false
    }

    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)

        if let closure = cellDescriptor?.performActionClosure ?? performAction {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return
            }
            
            closure(visibleRow, action, sender, indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender)
    }

    // MARK: Focus

    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return fallbackDelegate?.tableView?(tableView, canFocusRowAt: indexPath)
            ?? true
    }

    public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        return fallbackDelegate?.tableView?(tableView, shouldUpdateFocusIn: context)
            ?? true
    }

    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        fallbackDelegate?.tableView?(tableView, didUpdateFocusIn: context, with: coordinator)
    }

    public func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        return fallbackDelegate?.indexPathForPreferredFocusedView?(in: tableView)
    }
}

@available(iOS 11,*)
public extension DataSource {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.indices.count != 2 {
            // Problem: "Crash in IndexPath.section.getter"
            // When an indexPath has not exactly two indices, the getter for
            // `section` traps, causing crashes. This should not happen, but
            // sometimes it does anyways.
            return nil
        }
        let cellDescriptor = self.cellDescriptor(at: indexPath) as? CellDescriptorTypeiOS11
        if let closure = cellDescriptor?.trailingSwipeActionsClosure {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return nil
            }
            
            return closure(visibleRow, indexPath)
        } else {
            return fallbackDelegate?.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.indices.count != 2 {
            // Problem: "Crash in IndexPath.section.getter"
            // When an indexPath has not exactly two indices, the getter for
            // `section` traps, causing crashes. This should not happen, but
            // sometimes it does anyways.
            return nil
        }
        let cellDescriptor = self.cellDescriptor(at: indexPath) as? CellDescriptorTypeiOS11
        if let closure = cellDescriptor?.leadingSwipeActionsClosure {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return nil
            }
            
            return closure(visibleRow, indexPath)
        } else {
            return fallbackDelegate?.tableView?(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
        }
    }
}

@available(iOS 13,*)
public extension DataSource {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point _: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.indices.count != 2 {
            // Problem: "Crash in IndexPath.section.getter"
            // When an indexPath has not exactly two indices, the getter for
            // `section` traps, causing crashes. This should not happen, but
            // sometimes it does anyways.
            return nil
        }
        let cellDescriptor = self.cellDescriptor(at: indexPath) as? CellDescriptorTypeiOS13

        if let closure = cellDescriptor?.configurationForMenuAtLocationClosure {
            guard let visibleRow = visibleRow(at: indexPath) else {
                return nil
            }
            
            return closure(visibleRow, indexPath)
        } else {
            return fallbackDelegate?.tableView?(tableView, contextMenuConfigurationForRowAt: indexPath, point: CGPoint(x: 0, y: 0))
        }
    }
}

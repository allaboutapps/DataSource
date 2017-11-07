//
//  DataSource+UITableViewDelegate.swift
//  DataSource
//
//  Created by Matthias Buchetics on 21/02/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import Diff

extension DataSource: UITableViewDelegate {
    
    // MARK: Highlighting
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.shouldHighlightClosure ?? shouldHighlight {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, shouldHighlightRowAt: indexPath)
            ?? true
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.didHighlightClosure ?? didHighlight {
            closure(visibleRow(at: indexPath), indexPath)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, didHighlightRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.didUnhighlightClosure ?? didUnhighlight {
            closure(visibleRow(at: indexPath), indexPath)
            return
        }

        fallbackDelegate?.tableView?(tableView, didUnhighlightRowAt: indexPath)
    }
    
    // MARK: Selection
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.willSelectClosure ?? willSelect {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, willSelectRowAt: indexPath)
            ?? indexPath
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.willDeselectClosure ?? willDeselect {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, willDeselectRowAt: indexPath)
            ?? indexPath
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        
        if let closure = cellDescriptor.didSelectClosure ?? didSelect {
            let selectionResult = closure(visibleRow(at: indexPath), indexPath)
            
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
        
        if let closure = cellDescriptor.didDeselectClosure ?? didDeselect {
            closure(visibleRow(at: indexPath), indexPath)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    // MARK: Header & Footer
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionDescriptor = self.sectionDescriptor(at: section)
        
        if let closure = sectionDescriptor?.headerClosure ?? sectionHeader {
            let header = closure(visibleSection(at: section), section)
            
            switch header {
            case .view(let view):
                return view
            default:
                return nil
            }
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionDescriptor = self.sectionDescriptor(at: section)
        
        if let closure = sectionDescriptor?.footerClosure ?? sectionFooter {
            let footer = closure(visibleSection(at: section), section)
            
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
        
        if let closure = cellDescriptor.heightClosure ?? height {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, heightForRowAt: indexPath)
            ?? tableView.rowHeight
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.section
        let section = visibleSection(at: index)
        
        // Do not get the CellDescriptor if we are dealing with a LazySection because it would instaniate all the rows,
        // i.e. estimatedHeightClosure will not be called for LazySections. Instead, use the estimatedHeight on the 
        // DataSource, the fallback delegate or a constant.
        
        if !(section is LazySectionType) {
            let cellDescriptor = self.cellDescriptor(at: indexPath)
            
            if let closure = cellDescriptor.estimatedHeightClosure {
                return closure(visibleRow(at: indexPath), indexPath)
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
        
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionDescriptor = self.sectionDescriptor(at: section)

        if let closure = sectionDescriptor?.headerHeightClosure ?? sectionHeaderHeight {
            return closure(visibleSection(at: section), section).floatValue(for: tableView.style)
        }
        
        if let result =  fallbackDelegate?.tableView?(tableView, heightForHeaderInSection: section) {
            return result
        }
        
        if let headerClosure = sectionDescriptor?.headerClosure ?? sectionHeader {
            let header = headerClosure(visibleSection(at: section), section)
            
            switch header {
            case .title:
                return UITableViewAutomaticDimension
            case .view(let view):
                let height = view.bounds.height
                
                if height == 0 {
                    return tableView.sectionHeaderHeight > 0 ? tableView.sectionHeaderHeight : UITableViewAutomaticDimension
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
            return closure(visibleSection(at: section), section).floatValue(for: tableView.style)
        }
        
        if let result = fallbackDelegate?.tableView?(tableView, heightForFooterInSection: section) {
            return result
        }
        
        if let footerClosure = sectionDescriptor?.footerClosure ?? sectionFooter {
            let footer = footerClosure(visibleSection(at: section), section)
            
            switch footer {
            case .title:
                return UITableViewAutomaticDimension
            case .view(let view):
                let height = view.bounds.height
                
                if height == 0 {
                    return tableView.sectionFooterHeight > 0 ? tableView.sectionFooterHeight : UITableViewAutomaticDimension
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
        
        if let closure = cellDescriptor.willDisplayClosure ?? willDisplay {
            closure(visibleRow(at: indexPath), cell, indexPath)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, willDisplay:cell, forRowAt:indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let sectionDescriptor = self.sectionDescriptor(at: section)
        
        if let closure = sectionDescriptor?.willDisplayHeaderClosure ?? willDisplaySectionHeader {
            closure(visibleSection(at: section), view, section)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, willDisplayHeaderView:view, forSection:section)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let sectionDescriptor = self.sectionDescriptor(at: section)
        
        if let closure = sectionDescriptor?.willDisplayFooterClosure ?? willDisplaySectionFooter {
            closure(visibleSection(at: section), view, section)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, willDisplayFooterView:view, forSection:section)
    }
    
    // the didEnd delegate methods are only supported on a "fallback" level as we may not have the row or section
    // available at this point anymore and we don't want to keep a reference to old data
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let closure = didEndDisplaying {
            closure(cell, indexPath)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, didEndDisplaying:cell, forRowAt:indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let closure = didEndDisplayingSectionHeader {
            closure(view, section)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, didEndDisplayingHeaderView:view, forSection:section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if let closure = didEndDisplayingSectionFooter {
            closure(view, section)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, didEndDisplayingFooterView:view, forSection:section)
    }
    
    // MARK: Editing
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.editingStyleClosure ?? editingStyle {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        if let result = fallbackDelegate?.tableView?(tableView, editingStyleForRowAt:indexPath) {
            return result
        }
        
        if self.tableView(tableView, canEditRowAt: indexPath) {
            return .delete
        }
        
        return .none
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.titleForDeleteConfirmationButtonClosure ?? titleForDeleteConfirmationButton {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt:indexPath)
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.editActionsClosure ?? editActions {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, editActionsForRowAt:indexPath)
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.shouldIndentWhileEditingClosure ?? shouldIndentWhileEditing {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, shouldIndentWhileEditingRowAt:indexPath)
            ?? true
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.willBeginEditingClosure ?? willBeginEditing {
            closure(visibleRow(at: indexPath), indexPath)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, willBeginEditingRowAt:indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let closure = didEndEditing {
            closure(indexPath)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, didEndEditingRowAt:indexPath)
    }

    // MARK: Moving & Reordering
    
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let cellDescriptor = self.cellDescriptor(at: sourceIndexPath)
        
        if let closure = cellDescriptor.targetIndexPathForMoveClosure ?? targetIndexPathForMove {
            return closure(visibleRow(at: sourceIndexPath), (sourceIndexPath, proposedDestinationIndexPath))
        }
        
        return fallbackDelegate?.tableView?(tableView, targetIndexPathForMoveFromRowAt:sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
            ?? proposedDestinationIndexPath
    }
    
    
    // MARK: Indentation
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.indentationLevelClosure ?? indentationLevel {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, indentationLevelForRowAt: indexPath)
            ?? 0
    }
    
    // MARK: Copy & Paste
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.shouldShowMenuClosure ?? shouldShowMenu {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, shouldShowMenuForRowAt: indexPath)
            ?? false
    }
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.canPerformActionClosure ?? canPerformAction {
            return closure(visibleRow(at: indexPath), action, sender, indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender)
            ?? false
    }
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.performActionClosure ?? performAction {
            closure(visibleRow(at: indexPath), action, sender, indexPath)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender)
    }
    
    // MARK: Focus
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return fallbackDelegate?.tableView?(tableView, canFocusRowAt:indexPath)
            ?? true
    }
    
    public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        return fallbackDelegate?.tableView?(tableView, shouldUpdateFocusIn:context)
            ?? true
    }
    
    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        fallbackDelegate?.tableView?(tableView, didUpdateFocusIn:context, with:coordinator)
    }
    
    public func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        return fallbackDelegate?.indexPathForPreferredFocusedView?(in: tableView)
    }

}

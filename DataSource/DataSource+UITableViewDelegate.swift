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
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        let header = section.headerClosure?(section, sectionIndex) ?? sectionHeader?(section, sectionIndex)
        
        switch header {
        case .view(let view)?:
            return view
        default:
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        let footer = section.footerClosure?(section, sectionIndex) ?? sectionFooter?(section, sectionIndex)
        
        switch footer {
        case .view(let view)?:
            return view
        default:
            return nil
        }
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
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.estimatedHeightClosure ?? estimatedHeight {
            return closure(visibleRow(at: indexPath), indexPath)
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
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        if let closure = section.headerHeightClosure ?? sectionHeaderHeight {
            return closure(section, sectionIndex)
        }
        
        return fallbackDelegate?.tableView?(tableView, heightForHeaderInSection: sectionIndex)
            ?? UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        if let closure = section.footerHeightClosure ?? sectionFooterHeight {
            return closure(section, sectionIndex)
        }
        
        return fallbackDelegate?.tableView?(tableView, heightForFooterInSection: sectionIndex)
            ?? UITableViewAutomaticDimension
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
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        if let closure = section.willDisplayHeaderClosure ?? willDisplaySectionHeader {
            closure(section, view, sectionIndex)
        }
        
        fallbackDelegate?.tableView?(tableView, willDisplayHeaderView:view, forSection:sectionIndex)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        if let closure = section.willDisplayFooterClosure ?? willDisplaySectionFooter {
            closure(section, view, sectionIndex)
        }
        
        fallbackDelegate?.tableView?(tableView, willDisplayFooterView:view, forSection:sectionIndex)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.didEndDisplayingClosure ?? didEndDisplaying {
            closure(visibleRow(at: indexPath), cell, indexPath)
            return
        }
        
        fallbackDelegate?.tableView?(tableView, didEndDisplaying:cell, forRowAt:indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        if let closure = section.didEndDisplayingHeaderClosure ?? didEndDisplayingSectionHeader {
            closure(section, view, sectionIndex)
        }
        
        fallbackDelegate?.tableView?(tableView, didEndDisplayingHeaderView:view, forSection:sectionIndex)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        if let closure = section.didEndDisplayingFooterClosure ?? didEndDisplayingSectionFooter {
            closure(section, view, sectionIndex)
        }
        
        fallbackDelegate?.tableView?(tableView, didEndDisplayingFooterView:view, forSection:sectionIndex)
    }
    
    // MARK: Editing
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        
        if let closure = cellDescriptor.editingStyleClosure ?? editingStyle {
            return closure(visibleRow(at: indexPath), indexPath)
        }
        
        return fallbackDelegate?.tableView?(tableView, editingStyleForRowAt:indexPath)
            ?? .none
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
        if let indexPath = indexPath {
            let cellDescriptor = self.cellDescriptor(at: indexPath)
            
            if let closure = cellDescriptor.didEndEditingClosure ?? didEndEditing {
                closure(visibleRow(at: indexPath), indexPath)
                return
            }
        }
        
        fallbackDelegate?.tableView?(tableView, didEndEditingRowAt:indexPath)
    }

    // MARK: Moving & Reordering
    
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return fallbackDelegate?.tableView?(tableView, targetIndexPathForMoveFromRowAt:sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
            ?? proposedDestinationIndexPath
    }
    
    
    // MARK: Indentation
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return fallbackDelegate?.tableView?(tableView, indentationLevelForRowAt: indexPath)
            ?? 0
    }
    
    // MARK: Copy & Paste
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return fallbackDelegate?.tableView?(tableView, shouldShowMenuForRowAt: indexPath)
            ?? false
    }
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return fallbackDelegate?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender)
            ?? false
    }
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        fallbackDelegate?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender)
    }
    
    // MARK: Focus
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return fallbackDelegate?.tableView?(tableView, canFocusRowAt:indexPath)
            ?? false
    }
    
    public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        return fallbackDelegate?.tableView?(tableView, shouldUpdateFocusIn:context)
            ?? false
    }
    
    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        fallbackDelegate?.tableView?(tableView, didUpdateFocusIn:context, with:coordinator)
    }
    
    public func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        return fallbackDelegate?.indexPathForPreferredFocusedView?(in: tableView)
    }

}

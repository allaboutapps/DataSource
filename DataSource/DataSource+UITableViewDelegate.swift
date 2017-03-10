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
    
    // NOTE: estimated section header and footer heights are not supported
}

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
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.shouldHighlightClosure ?? shouldHighlight {
            return closure(row, indexPath)
        } else {
            return fallbackDelegate?.tableView?(tableView, shouldHighlightRowAt: indexPath) ?? true
        }
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.didHighlightClosure ?? didHighlight {
            closure(row, indexPath)
        } else {
            fallbackDelegate?.tableView?(tableView, didHighlightRowAt: indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.didHighlightClosure ?? didUnhighlight {
            closure(row, indexPath)
        } else {
            fallbackDelegate?.tableView?(tableView, didUnhighlightRowAt: indexPath)
        }
    }
    
    // MARK: Selection
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.willSelectClosure ?? willSelect {
            return closure(row, indexPath)
        } else {
            return fallbackDelegate?.tableView?(tableView, willSelectRowAt: indexPath) ?? indexPath
        }
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.willDeselectClosure ?? willDeselect {
            return closure(row, indexPath)
        } else {
            return fallbackDelegate?.tableView?(tableView, willDeselectRowAt: indexPath) ?? indexPath
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.didSelectClosure ?? didSelect {
            let selectionResult = closure(row, indexPath)
            
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
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.didDeselectClosure ?? didDeselect {
            closure(row, indexPath)
        } else {
            fallbackDelegate?.tableView?(tableView, didDeselectRowAt: indexPath)
        }
    }
    
    // MARK: Header & Footer
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        switch section.headerClosure?(section, sectionIndex) {
        case .view(let view)?:
            return view
        default:
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionIndex = section
        let section = sections[sectionIndex]
        
        switch section.footerClosure?(section, sectionIndex) {
        case .view(let view)?:
            return view
        default:
            return nil
        }
    }
    
    // MARK: Height
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.heightClosure ?? height {
            return closure(row, indexPath)
        } else {
            return fallbackDelegate?.tableView?(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
        }
    }
}

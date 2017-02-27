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
            fallbackDelegate?.tableView!(tableView, didSelectRowAt: indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let index = section
        let section = sections[index]
        
        switch section.headerClosure?(section, index) {
        case .view(let view)?:
            return view
        default:
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let index = section
        let section = sections[index]
        
        switch section.footerClosure?(section, index) {
        case .view(let view)?:
            return view
        default:
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellDescriptor = self.cellDescriptor(at: indexPath)
        let row = self.visibleRow(at: indexPath)
        
        if let closure = cellDescriptor.heightClosure ?? height {
            return closure(row, indexPath)
        } else {
            return fallbackDelegate?.tableView!(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
        }
    }
}

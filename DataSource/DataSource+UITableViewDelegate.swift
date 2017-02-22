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
        let row = self.row(at: indexPath)
        
        if let closure = cellDescriptor.didSelectClosure ?? didSelect {
            let selectionResult = closure(row, indexPath)
            
            switch selectionResult {
            case .deselect:
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                break
            }
        } else {
            fallbackDelegate?.tableView!(tableView, didSelectRowAt: indexPath)
        }
    }
}

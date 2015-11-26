//
//  UITableViewExtensions.swift
//  Example
//
//  Created by Matthias Buchetics on 25/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    public func registerNib(identifier: String) {
        registerNib(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
    
    public func heightForHeaderInSection(section: SectionType) -> CGFloat {
        return heightForHeaderFooterInSection(section, defaultHeight: sectionHeaderHeight)
    }
    
    public func heightForFooterInSection(section: SectionType) -> CGFloat {
        let footerHeight = style == .Grouped ? sectionFooterHeight : 0
        return heightForHeaderFooterInSection(section, defaultHeight: footerHeight)
    }
    
    /**
        Returns the height for section headers and footers.
        We only want to show a section if it has any rows and we only want to show a section header if it has a title.
        Used to fix an issue where the section header height of empty sections in a grouped table view is calculated wrong by iOS.
    */
    func heightForHeaderFooterInSection(section: SectionType, defaultHeight: CGFloat) -> CGFloat {
        if style == .Grouped {
            return section.numberOfRows > 0 ? defaultHeight : CGFloat.min
        }
        else {
            return (section.numberOfRows > 0 && section.hasTitle) ? defaultHeight : 0
        }
    }
}
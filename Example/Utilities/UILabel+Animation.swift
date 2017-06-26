//
//  UILabel+Animation.swift
//  DataSource
//
//  Created by Matthias Buchetics on 17/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

extension UILabel {
    
    func update(text: String?, animated: Bool) {
        if animated {
            UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                self.text = text
            }, completion: nil)
        } else {
            self.text = text
        }
    }
}

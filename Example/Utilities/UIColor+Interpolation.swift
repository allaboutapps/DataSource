//
//  UIColor+Interpolation.swift
//  DataSource
//
//  Created by Matthias Buchetics on 09/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

extension UIColor {
    
    var components: [CGFloat]? {
        guard let components = cgColor.components else { return nil }
        
        if components.count == 2 {
            return [components[0], components[0], components[0], components[1]]
        } else {
            return components
        }
    }
    
    static func interpolate(from: UIColor, to: UIColor, fraction: Double) -> UIColor {
        let f = CGFloat(min(1.0, max(0.0, fraction))) // clamp between 0 and 1
        
        guard let c1 = from.components else { return from }
        guard let c2 = to.components else { return to }
        
        let r = CGFloat(c1[0] + (c2[0] - c1[0]) * f)
        let g = CGFloat(c1[1] + (c2[1] - c1[1]) * f)
        let b = CGFloat(c1[2] + (c2[2] - c1[2]) * f)
        let a = CGFloat(c1[3] + (c2[3] - c1[3]) * f)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

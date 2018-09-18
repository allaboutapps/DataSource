//
//  UIView+AutoLayout.swift
//  StappOne
//
//  Created by Matthias Buchetics on 15.01.18.
//  Copyright © 2018 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

extension UIView {
    
    func animateConstraints(withDuration duration: TimeInterval, delay: TimeInterval = 0.0, animations: () -> Void) {
        animateConstraints(withDuration: duration, delay: delay, animations: animations, completion: nil)
    }
    
    func animateConstraints(withDuration duration: TimeInterval, delay: TimeInterval = 0.0, animations: () -> Void, completion: ((Bool) -> Void)?) {
        self.layoutIfNeeded()
        animations()
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions(rawValue: 0), animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    func animateConstraints(withDuration duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) {
        self.layoutIfNeeded()
        animations()
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    @discardableResult func withConstraints(_ closure: (_ view: UIView) -> [NSLayoutConstraint]) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(closure(self))
        return self
    }
    
    // Layout guide
    
    func alignLeading(_ layoutGuide: UILayoutGuide, constant: CGFloat = 0) -> NSLayoutConstraint {
        return leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: constant)
    }
    
    func alignTrailing(_ layoutGuide: UILayoutGuide, constant: CGFloat = 0) -> NSLayoutConstraint {
        return trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: constant)
    }
    
    func alignLeft(_ layoutGuide: UILayoutGuide, constant: CGFloat = 0) -> NSLayoutConstraint {
        return leftAnchor.constraint(equalTo: layoutGuide.leftAnchor, constant: constant)
    }
    
    func alignRight(_ layoutGuide: UILayoutGuide, constant: CGFloat = 0) -> NSLayoutConstraint {
        return rightAnchor.constraint(equalTo: layoutGuide.rightAnchor, constant: constant)
    }
    
    func alignTop(_ layoutGuide: UILayoutGuide, constant: CGFloat = 0) -> NSLayoutConstraint {
        return topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: constant)
    }
    
    func alignBottom(_ layoutGuide: UILayoutGuide, constant: CGFloat = 0) -> NSLayoutConstraint {
        return bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: constant)
    }
    
    // View
    
    func alignLeading(_ view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        return leadingAnchor.constraint(equalTo: anchorView(view).leadingAnchor, constant: constant)
    }
    
    func alignTrailing(_ view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        return trailingAnchor.constraint(equalTo: anchorView(view).trailingAnchor, constant: constant)
    }
    
    func alignLeft(_ view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        return leftAnchor.constraint(equalTo: anchorView(view).leftAnchor, constant: constant)
    }
    
    func alignRight(_ view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        return rightAnchor.constraint(equalTo: anchorView(view).rightAnchor, constant: constant)
    }
    
    func alignTop(_ view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        return topAnchor.constraint(equalTo: anchorView(view).topAnchor, constant: constant)
    }
    
    func alignBottom(_ view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        return bottomAnchor.constraint(equalTo: anchorView(view).bottomAnchor, constant: constant)
    }
    
    func alignCenterX(_ view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        return centerXAnchor.constraint(equalTo: anchorView(view).centerXAnchor, constant: constant)
    }
    
    func alignCenterY(_ view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        return centerYAnchor.constraint(equalTo: anchorView(view).centerYAnchor, constant: constant)
    }
    
    func alignCenter(_ view: UIView? = nil) -> [NSLayoutConstraint] {
        return [
            alignCenterX(view),
            alignCenterY(view)
        ]
    }
    
    func alignEdges(_ view: UIView? = nil, insets: UIEdgeInsets = UIEdgeInsets.init()) -> [NSLayoutConstraint] {
        return [
            alignLeft(view, constant: insets.left),
            alignRight(view, constant: -insets.right),
            alignTop(view, constant: insets.top),
            alignBottom(view, constant: -insets.bottom)
        ]
    }
    
    func constraintWidth(_ width: CGFloat) -> NSLayoutConstraint {
        return widthAnchor.constraint(equalToConstant: width)
    }
    
    func constraintHeight(_ height: CGFloat) -> NSLayoutConstraint {
        return heightAnchor.constraint(equalToConstant: height)
    }
    
    func constraintSize(_ size: CGSize) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ]
    }
    
    private func anchorView(_ view: UIView?) -> UIView {
        return view ?? superview!
    }
}

extension Array where Element: NSLayoutConstraint {
    func activate() {
        NSLayoutConstraint.activate(self)
    }
    
    func priority(_ priority: UILayoutPriority) -> [NSLayoutConstraint] {
        for constraint in self {
            constraint.priority = priority
        }
        
        return self
    }
}

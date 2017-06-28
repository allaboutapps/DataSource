//
//  DataSource+UIScrollViewDelegate.swift
//  DataSource
//
//  Created by Gunter Hager on 28/06/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

extension DataSource: UIScrollViewDelegate {
    
    // MARK: Responding to Scrolling and Dragging
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let closure = didScroll {
            closure(scrollView)
        } else {
            fallbackDelegate?.scrollViewDidScroll?(scrollView)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        fallbackDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        fallbackDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        fallbackDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return fallbackDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        fallbackDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        fallbackDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        fallbackDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    // MARK: Managing Zooming
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fallbackDelegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        fallbackDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        fallbackDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        fallbackDelegate?.scrollViewDidZoom?(scrollView)
    }
    
    // MARK: Responding to Scrolling Animations
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        fallbackDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
}

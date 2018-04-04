//
//  SectionDescriptor.swift
//  DataSource
//
//  Created by Matthias Buchetics on 15/03/2017.
//  Copyright © 2017 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

public enum HeaderFooter {
    
    case none
    case title(String)
    case view(UIView)
}

public enum SectionHeight {
    
    case value(_: CGFloat)
    case automatic
    case zero
    
    func floatValue(for style: UITableViewStyle) -> CGFloat {
        switch self {
        case .value(let value):
            return value
        case .automatic:
            return UITableViewAutomaticDimension
        case .zero:
            return style == .plain ? 0.0 : CGFloat.leastNormalMagnitude
        }
    }
}

// MARK - SectionDescriptorType

public protocol SectionDescriptorType {
    
    var identifier: String { get }
    
    var isHiddenClosure: ((SectionType, Int) -> Bool)? { get }
    
    // UITableViewDelegate
    
    var headerClosure: ((SectionType, Int) -> HeaderFooter)? { get }
    var footerClosure: ((SectionType, Int) -> HeaderFooter)? { get }
    
    var headerHeightClosure: ((SectionType, Int) -> SectionHeight)? { get }
    var footerHeightClosure: ((SectionType, Int) -> SectionHeight)? { get }
    
    var willDisplayHeaderClosure: ((SectionType, UIView, Int) -> Void)? { get }
    var willDisplayFooterClosure: ((SectionType, UIView, Int) -> Void)? { get }
}

// MARK - SectionDescriptor

public class SectionDescriptor<HeaderFooterContent>: SectionDescriptorType {
    
    public let identifier: String
    
    public init(_ identifier: String? = nil) {
        if let identifier = identifier {
            self.identifier = identifier
        } else if HeaderFooterContent.self != Void.self {
            self.identifier = String(describing: HeaderFooterContent.self)
        } else {
            self.identifier = ""
        }
    }
    
    // MARK: Typed Getters
    
    private func typedContent(_ section: SectionType) -> HeaderFooterContent {
        guard let content = section.content as? HeaderFooterContent else {
            fatalError("[DataSource] could not cast to expected section content type \(HeaderFooterContent.self)")
        }
        return content
    }
    
    // MARK: - UITableViewDelegate
    
    // MARK: isHidden
    
    public private(set) var isHiddenClosure: ((SectionType, Int) -> Bool)?
    
    public func isHidden(_ closure: @escaping (HeaderFooterContent, Int) -> Bool) -> SectionDescriptor {
        isHiddenClosure = { (section, index) in
            closure(self.typedContent(section), index)
        }
        return self
    }
    
    public func isHidden(_ closure: @escaping () -> Bool) -> SectionDescriptor {
        isHiddenClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: header
    
    public private(set) var headerClosure: ((SectionType, Int) -> HeaderFooter)?
    
    public func header(_ closure: @escaping (HeaderFooterContent, Int) -> HeaderFooter) -> SectionDescriptor {
        headerClosure = { [unowned self] (section, index) in
            closure(self.typedContent(section), index)
        }
        return self
    }
    
    public func header(_ closure: @escaping () -> HeaderFooter) -> SectionDescriptor {
        headerClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: footer
    
    public private(set) var footerClosure: ((SectionType, Int) -> HeaderFooter)?
    
    public func footer(_ closure: @escaping (HeaderFooterContent, Int) -> HeaderFooter) -> SectionDescriptor {
        footerClosure = { [unowned self] (section, index) in
            closure(self.typedContent(section), index)
        }
        return self
    }
    
    public func footer(_ closure: @escaping () -> HeaderFooter) -> SectionDescriptor {
        footerClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: headerHeight
    
    public private(set) var headerHeightClosure: ((SectionType, Int) -> SectionHeight)?
    
    public func headerHeight(_ closure: @escaping (HeaderFooterContent, Int) -> SectionHeight) -> SectionDescriptor {
        headerHeightClosure = {  [unowned self](section, index) in
            closure(self.typedContent(section), index)
        }
        return self
    }
    
    public func headerHeight(_ closure: @escaping () -> SectionHeight) -> SectionDescriptor {
        headerHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: footerHeight
    
    public private(set) var footerHeightClosure: ((SectionType, Int) -> SectionHeight)?
    
    public func footerHeight(_ closure: @escaping (HeaderFooterContent, Int) -> SectionHeight) -> SectionDescriptor {
        footerHeightClosure = { [unowned self] (section, index) in
            closure(self.typedContent(section), index)
        }
        return self
    }
    
    public func footerHeight(_ closure: @escaping () -> SectionHeight) -> SectionDescriptor {
        footerHeightClosure = { (_, _) in
            closure()
        }
        return self
    }
    
    // MARK: willDisplayHeader
    
    public private(set) var willDisplayHeaderClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func willDisplayHeader(_ closure: @escaping (HeaderFooterContent, UIView, Int) -> Void) -> SectionDescriptorType {
        willDisplayHeaderClosure = { [unowned self] (section, view, index) in
            closure(self.typedContent(section), view, index)
        }
        return self
    }
    
    public func willDisplayHeader(_ closure: @escaping () -> Void) -> SectionDescriptor {
        willDisplayHeaderClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: willDisplayFooter
    
    public private(set) var willDisplayFooterClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func willDisplayFooter(_ closure: @escaping (HeaderFooterContent, UIView, Int) -> Void) -> SectionDescriptorType {
        willDisplayFooterClosure = { [unowned self] (section, view, index) in
            closure(self.typedContent(section), view, index)
        }
        return self
    }
    
    public func willDisplayFooter(_ closure: @escaping () -> Void) -> SectionDescriptor {
        willDisplayFooterClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: didEndDisplayingHeader
    
    public private(set) var didEndDisplayingHeaderClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func didEndDisplayingHeader(_ closure: @escaping (HeaderFooterContent, UIView, Int) -> Void) -> SectionDescriptorType {
        didEndDisplayingHeaderClosure = { [unowned self] (section, view, index) in
            closure(self.typedContent(section), view, index)
        }
        return self
    }
    
    public func didEndDisplayingHeader(_ closure: @escaping () -> Void) -> SectionDescriptor {
        didEndDisplayingHeaderClosure = { (_, _, _) in
            closure()
        }
        return self
    }
    
    // MARK: didEndDisplayingFooter
    
    public private(set) var didEndDisplayingFooterClosure: ((SectionType, UIView, Int) -> Void)?
    
    public func didEndDisplayingFooter(_ closure: @escaping (HeaderFooterContent, UIView, Int) -> Void) -> SectionDescriptorType {
        didEndDisplayingFooterClosure = { [unowned self] (section, view, index) in
            closure(self.typedContent(section), view, index)
        }
        return self
    }
    
    public func didEndDisplayingFooter(_ closure: @escaping () -> Void) -> SectionDescriptor {
        didEndDisplayingFooterClosure = { (_, _, _) in
            closure()
        }
        return self
    }
}

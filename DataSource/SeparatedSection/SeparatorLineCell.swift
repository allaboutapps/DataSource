//
//  TableViewCell.swift
//  Revier
//
//  Created by Stefan Draskovits on 08.06.18.
//  Copyright © 2018 allaboutapps. All rights reserved.
//

import UIKit

public struct SeparatorStyle: Equatable {
    
    public let edgeEnsets: UIEdgeInsets
    public let color: UIColor
    public let backgroundColor: UIColor
    public let height: CGFloat
    
    public static let defaultColor = UIColor(red: 203.0 / 255.0, green: 203.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
    
    public init(edgeEnsets: UIEdgeInsets = .zero, color: UIColor = SeparatorStyle.defaultColor, backgroundColor: UIColor = .white, height: CGFloat = 1.0) {
        self.edgeEnsets = edgeEnsets
        self.color = color
        self.backgroundColor = backgroundColor
        self.height = height
    }
    
    public init(leftInset: CGFloat, color: UIColor = SeparatorStyle.defaultColor, backgroundColor: UIColor = .white, height: CGFloat = 1.0) {
        self.init(edgeEnsets: UIEdgeInsets(top: 0.0, left: leftInset, bottom: 0.0, right: 0.0),
                  color: color,
                  backgroundColor: backgroundColor,
                  height: height)
    }
    
}

class SeparatorLineViewModel: Diffable {
    
    let diffIdentifier: String
    let style: SeparatorStyle?
    let customView: UIView?
    
    init(diffIdentifier: String, style: SeparatorStyle) {
        self.diffIdentifier = diffIdentifier
        self.style = style
        self.customView = nil
    }
    
    init(diffIdentifier: String, customView: UIView?) {
        self.diffIdentifier = diffIdentifier
        self.style = nil
        self.customView = customView
    }
    
    var row: RowType {
        return Row(self)
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? SeparatorLineViewModel else { return false }
        if let otherStlye = other.style, let selfStyle = self.style {
            return otherStlye == selfStyle
        } else {
            return false
        }
    }
    
}

class SeparatorLineCell: UITableViewCell {

    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var leftInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var topInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomInsetConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        separator.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    func configure(viewModel: SeparatorLineViewModel) {
        if let style = viewModel.style {
            separator.backgroundColor = style.color
            backgroundColor = style.backgroundColor
            leftInsetConstraint.constant = style.edgeEnsets.left
            rightInsetConstraint.constant = style.edgeEnsets.right
            topInsetConstraint.constant = style.edgeEnsets.top
            bottomInsetConstraint.constant = style.edgeEnsets.bottom
        } else if let customView = viewModel.customView {
            separator.addSubview(customView)
            customView.withConstraints { (view) -> [NSLayoutConstraint] in
                view.alignEdges()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftInsetConstraint.constant = 0
        rightInsetConstraint.constant = 0
        topInsetConstraint.constant = 0
        bottomInsetConstraint.constant = 0
        separator.subviews.forEach { $0.removeFromSuperview() }
        separator.backgroundColor = .clear
        backgroundColor = .clear
    }
    
}

extension SeparatorLineCell {
    
    static var descriptor: CellDescriptor<SeparatorLineViewModel, SeparatorLineCell> {
        return CellDescriptor(bundle: Bundle(for: SeparatorLineCell.self))
            .configure { (viewModel, cell, _) in
                cell.configure(viewModel: viewModel)
            }.height { (viewModel, _) -> CGFloat in
                if let stlye = viewModel.style {
                    return stlye.height
                } else if viewModel.customView != nil {
                    return UITableView.automaticDimension
                } else {
                    return 0
                }
            }
    }
    
}

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
    
    /// One pixle, depending on screen resolution
    public static let defaultLineHeight: CGFloat = 1.0 / UIScreen.main.scale
    
    public init(edgeEnsets: UIEdgeInsets = .zero, color: UIColor = SeparatorStyle.defaultColor, backgroundColor: UIColor = .white, height: CGFloat = SeparatorStyle.defaultLineHeight) {
        self.edgeEnsets = edgeEnsets
        self.color = color
        self.backgroundColor = backgroundColor
        self.height = height
    }
    
    public init(leftInset: CGFloat, color: UIColor = SeparatorStyle.defaultColor, backgroundColor: UIColor = .white, height: CGFloat = SeparatorStyle.defaultLineHeight) {
        self.init(edgeEnsets: UIEdgeInsets(top: 0.0, left: leftInset, bottom: 0.0, right: 0.0),
                  color: color,
                  backgroundColor: backgroundColor,
                  height: height)
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
        let style = viewModel.style
        separator.backgroundColor = style.color
        backgroundColor = style.backgroundColor
        leftInsetConstraint.constant = style.edgeEnsets.left
        rightInsetConstraint.constant = style.edgeEnsets.right
        topInsetConstraint.constant = style.edgeEnsets.top
        bottomInsetConstraint.constant = style.edgeEnsets.bottom
    }
    
    func configure(viewModel: SeparatorCustomViewViewModel) {
        let customView = viewModel.customView
        separator.addSubview(customView)
        customView.withConstraints { (view) -> [NSLayoutConstraint] in
            view.alignEdges()
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
    
    static var descriptorLine: CellDescriptor<SeparatorLineViewModel, SeparatorLineCell> {
        return CellDescriptor(bundle: Bundle(for: SeparatorLineCell.self))
            .configure { (viewModel, cell, _) in
                cell.configure(viewModel: viewModel)
            }.height { (viewModel, _) -> CGFloat in
                return viewModel.style.height
            }
    }
    
    static var descriptorCustomView: CellDescriptor<SeparatorCustomViewViewModel, SeparatorLineCell> {
        return CellDescriptor(bundle: Bundle(for: SeparatorLineCell.self))
            .configure { (viewModel, cell, _) in
                cell.configure(viewModel: viewModel)
            }.height { (_, _) -> CGFloat in
                return UITableView.automaticDimension
            }
    }
    
}

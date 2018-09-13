//
//  TableViewCell.swift
//  Revier
//
//  Created by Stefan Draskovits on 08.06.18.
//  Copyright © 2018 allaboutapps. All rights reserved.
//

import UIKit

public struct SeparatorStyle {
    public let leftInset: CGFloat
    public let rightInset: CGFloat
    public let color: UIColor
    public let height: CGFloat
    
    public static let defualtColor = UIColor(red: 203.0 / 255.0, green: 203.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
    
    public init(leftInset: CGFloat = 0.0, rightInset: CGFloat = 0.0, color: UIColor = SeparatorStyle.defualtColor, height: CGFloat = 1.0) {
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.color = color
        self.height = height
    }
    
}

class SeparatorLineViewModel: Diffable {
    
    let diffIdentifier: String
    let style: SeparatorStyle
    
    init(diffIdentifier: String, style: SeparatorStyle) {
        self.diffIdentifier = diffIdentifier
        self.style = style
    }
    
    var row: RowType {
        return Row(self)
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        return false
    }
    
}

class SeparatorLineCell: UITableViewCell {

    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var leftInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightInsetConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .clear
    }
    
    func configure(viewModel: SeparatorLineViewModel) {
        separator.backgroundColor = viewModel.style.color
        leftInsetConstraint.constant = viewModel.style.leftInset
        rightInsetConstraint.constant = viewModel.style.rightInset
    }
    
}

extension SeparatorLineCell {
    static var descriptor: CellDescriptor<SeparatorLineViewModel, SeparatorLineCell> {
        return CellDescriptor(bundle: Bundle(for: SeparatorLineCell.self))
            .configure { (viewModel, cell, _) in
                cell.configure(viewModel: viewModel)
            }.height { (viewModel, _) -> CGFloat in
                return viewModel.style.height
            }
    }
}

//
//  ButtonCell
//  Example
//
//  Created by Matthias Buchetics on 25/11/15.
//  Copyright © 2015 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray()
        selectedBackgroundView = backgroundView
    }
}

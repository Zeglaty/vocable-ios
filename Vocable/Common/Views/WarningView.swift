//
//  WarningView.swift
//  Vocable
//
//  Created by Martin Pittenauer on 20.03.20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable
class WarningView: UIView {

    @IBOutlet weak var label: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        label?.text = NSLocalizedString("Please move closer to the device.", comment: "Warning: Please move closer to the device.")
    }
}

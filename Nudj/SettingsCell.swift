//
//  SettingsCell.swift
//  Nudj
//
//  Created by Lachezar Todorov on 6.04.15.
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setTitle(text: String) {
        self.textLabel!.text = text;
    }

    func alignCenter() {
        self.textLabel!.textAlignment = NSTextAlignment.Center
    }

    func alignLeft() {
        self.textLabel!.textAlignment = NSTextAlignment.Left
    }

}

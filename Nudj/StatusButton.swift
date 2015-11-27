//
//  StatusButton.swift
//  Nudge
//
//  Created by Lachezar Todorov on 10.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

struct Status {
    // TODO: localisation
    static let titles = ["Hiring", "Available", "Do not Disturb"]
    // TODO: magic numbers
    static let colors = [
        UIColor(red: 22.0/255.0, green: 128.0/255.0, blue: 175.0/255.0, alpha: 1.0), 
        UIColor(red: 0.0, green: 0.63, blue: 0.53, alpha: 1.0), 
        UIColor(red: 0.63, green: 0.0, blue: 0.0, alpha: 1.0)]
}

class StatusButton: UIButton {
    // TODO: localisation
    let initialTitle = "SELECT STATUS"

    var gray = true
    var isChanged = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    func setup() {
        // TODO: magic numbers
        self.titleLabel?.font = self.titleLabel?.font.fontWithSize(10)
        self.setTitle(self.initialTitle, forState: UIControlState.Normal)

        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1

        // TODO: magic numbers
        self.contentEdgeInsets = UIEdgeInsets(top: 3, left: 13, bottom: 3, right: 13)
        self.sizeToFit()
    }

    func setTitle(title: String) {
        self.setTitle(title, forState: UIControlState.Normal)
        isChanged = true
    }

    func setTitleByIndex(title: Int) {
        if (!self.isValidStatus(title)) {
            self.setTitle("", forState: UIControlState.Normal)
            isChanged = false
        } else {
            self.setTitle(Status.titles[title], forState: UIControlState.Normal)
            self.changeColor(Status.colors[title])
            isChanged = true
        }
    }

    func changeColor(color: UIColor) {
        self.layer.borderColor = color.CGColor
        self.setTitleColor(color, forState: UIControlState.Normal)
    }

    func isSelectedStatus() -> Bool {
        return isChanged
    }

    func isValidStatus(index: Int) -> Bool {
        return index >= 0 && index < Status.titles.count
    }
}

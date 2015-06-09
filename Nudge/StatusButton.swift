//
//  StatusButton.swift
//  Nudge
//
//  Created by Lachezar Todorov on 10.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

struct Status {
    static let titles = ["Inactive", "Hiring"]
    static let colors = [UIColor.lightGrayColor(), UIColor(red: 0, green: 0.63, blue: 0.53, alpha: 1)]
}

class StatusButton: UIButton {

    let initialTitle = "SELECT STATUS"

    var gray = true

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    func setup() {
        self.titleLabel?.font = self.titleLabel?.font.fontWithSize(10)
        self.setTitle(self.initialTitle, forState: UIControlState.Normal)

        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1

        self.contentEdgeInsets = UIEdgeInsets(top: 3, left: 13, bottom: 3, right: 13)
        self.sizeToFit()
    }

    func setTitle(title: String) {
        self.setTitle(title, forState: UIControlState.Normal)
    }

    func setTitleByIndex(title: Int) {

        if (!self.isValidStatus(title)) {
            self.setTitle("", forState: UIControlState.Normal)
        } else {
            self.setTitle(Status.titles[title], forState: UIControlState.Normal)
            self.changeColor(Status.colors[title])
        }
    }

    func changeColor(color: UIColor) {
        self.layer.borderColor = color.CGColor
        self.setTitleColor(color, forState: UIControlState.Normal)
    }

    func isValidStatus(index: Int) -> Bool {
        return index >= 0 && index < Status.titles.count
    }
}

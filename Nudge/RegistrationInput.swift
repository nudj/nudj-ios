//
//  RegistrationInput.swift
//  Nudge
//
//  Created by Lachezar Todorov on 4.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

class RegistrationInput: UITextField {

    let left: UILabel = UILabel()
    let prefixPadding:CGFloat = 20
    let prefixBorderWidth:CGFloat = 1
    let prefixBorderAlpha:CGFloat = 0.2
    let prefix = "+44"

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupPrefix(self.prefix)
    }

    func setupPrefix(text: String) {
        left.numberOfLines = 0
        left.text = self.prefix
        left.textAlignment = NSTextAlignment.Center
        left.sizeToFit()

        var tmpFrame = left.frame;
        tmpFrame.size.height = self.frame.size.height
        tmpFrame.size.width += prefixPadding
        left.frame = tmpFrame

        applyRightBorder(left)

        self.leftView = left;
        self.leftViewMode = UITextFieldViewMode.Always;
    }

    func applyRightBorder(obj: UIView) {
        let view = UIView(frame: CGRect(x: obj.frame.size.width - prefixBorderWidth, y: 0, width: prefixBorderWidth, height: obj.frame.size.height));
        view.layer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(prefixBorderAlpha).CGColor
        obj.addSubview(view)
    }

    func getCleanNumber(number: String? = nil) -> String {
        guard let value: String = number ?? self.text else {
            return ""
        }
        
        var characters = value.characters
        while characters.first == "0" {
            characters = characters.dropFirst()
        }
        return String(characters)
    }

    func getFormattedNumber() -> String {
        return prefix + self.getCleanNumber()
    }

}

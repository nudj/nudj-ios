//
//  VerifyCodeTextField.swift
//  Nudge
//
//  Created by Lachezar Todorov on 7.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

class VerifyCodeTextField: UITextField {

    let padding:CGFloat = 6

    let lineWidth:CGFloat = 1.8

    let textFont = UIFont.systemFontOfSize(34)
    let letterSpacing:CGFloat = 23.5;

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    func setup() {
        leftViewMode = UITextFieldViewMode.Always;

        leftView = UIView(frame: CGRect(x: 0, y: 0, width: letterSpacing/2, height: letterSpacing/2))

        layout()
    }

    func layout() {
        var newText = NSMutableAttributedString(string: text!)

        let limit = count(text!) > 3 ? 3 : count(text!)

        newText.addAttributes([
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor], range: NSRange(location: 0, length: count(text!)))

        newText.addAttribute(NSKernAttributeName, value: letterSpacing, range: NSRange(location: 0, length: limit))

        self.attributedText = newText
        self.adjustsFontSizeToFitWidth = true
    }

    override func drawRect(rect: CGRect) {

        UIColor.grayColor().setStroke()

        let section = rect.width / 4;

        var border = UIBezierPath(rect: rect);
        border.lineWidth = lineWidth
        border.stroke()

        var path = UIBezierPath()

        path.lineWidth = lineWidth

        for(var i:CGFloat = 1; i < 4; i++) {
            let meridian:CGFloat = section * i;
            path.moveToPoint(CGPoint(x: meridian, y: padding))
            path.addLineToPoint(CGPoint(x: meridian, y: rect.height - padding))
        }

        path.stroke()
        super.drawRect(rect)

    }

}

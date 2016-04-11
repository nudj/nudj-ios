//
//  VerifyCodeTextField.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class VerifyCodeTextField: UITextField {
    // TODO: magic numbers
    let padding:CGFloat = 6
    let lineWidth:CGFloat = 1.8
    let textFont = UIFont.systemFontOfSize(34)
    let letterSpacing:CGFloat = 27;

    required init?(coder aDecoder: NSCoder) {
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
        let oldText = text ?? ""
        let newText = NSMutableAttributedString(string: oldText)
        let numChars = oldText.characters.count
        let limit = min(3, numChars)

        newText.addAttributes([
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor!], range: NSRange(location: 0, length: numChars))

        newText.addAttribute(NSKernAttributeName, value: letterSpacing, range: NSRange(location: 0, length: limit))

        self.attributedText = newText
        self.adjustsFontSizeToFitWidth = true
    }

    override func drawRect(rect: CGRect) {
        UIColor.grayColor().setStroke()
        let section = rect.width / 4
        let	 border = UIBezierPath(rect: rect)
        border.lineWidth = lineWidth
        border.stroke()

        let path = UIBezierPath()
        path.lineWidth = lineWidth
        for i in 1 ..< 4 {
            let meridian: CGFloat = section * CGFloat(i)
            path.moveToPoint(CGPoint(x: meridian, y: padding))
            path.addLineToPoint(CGPoint(x: meridian, y: rect.height - padding))
        }
        path.stroke()
        
        super.drawRect(rect)
    }
}

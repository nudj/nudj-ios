//
//  Common.swift
//  Nudge
//
//  Created by Lachezar Todorov on 8.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation

class Common {

    static func automateUpdatingOfAssets(field: UIView, icon:UIImageView? = nil, label:UILabel? = nil) {
        var hasInput = false

        if let textView = field as? UITextView {
            hasInput = count(textView.text) > 0
        } else if let textField = field as? UITextField {
            hasInput = count(textField.text) > 0
        } else if let tokenView = field as? TokenView {
            hasInput = tokenView.tokens()?.count > 0
        }

        icon?.highlighted = hasInput
        label?.hidden = hasInput
    }

}
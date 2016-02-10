//
//  NoContentPlaceHolder.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class NoContentPlaceHolder: UIImageView {
    // TODO: magic numbers
    let imageWidth: CGFloat = 200.0
    let imageHeight: CGFloat = 149.0

    func alignInSuperView(superview: UIView, imageTitle: String) -> NoContentPlaceHolder {
        let size = superview.frame.size
        self.frame = CGRectMake((size.width - imageWidth) / 2.0, (size.height - imageHeight) / 2.0, imageWidth, imageHeight)
        self.image = UIImage(named: imageTitle)
        self.hidden = true
        
        return self
    }
}

//
//  UIScrollViewCategory.swift
//  Nudge
//
//  Created by Lachezar Todorov on 11.06.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

extension UIScrollView {

    public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("touchesBegan: " + (self.dragging ? "1" : "0"))
        println("in ScrollView: " + (self.isKindOfClass(UIScrollView) ? "1" : "0"))
        println("Next, Self: : ", self.nextResponder(), self)
//        if (!self.dragging) {
//            self.nextResponder()?.touchesBegan(touches, withEvent: event)
//        } else {
//            super.touchesBegan(touches, withEvent: event)
//        }
        super.touchesBegan(touches, withEvent: event)
    }

//    public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
//        if (!self.dragging) {
//            self.nextResponder()?.touchesMoved(touches, withEvent: event)
//        } else {
//            super.touchesMoved(touches, withEvent: event)
//        }
//    }
//
//    public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
//        if (!self.dragging) {
//            self.nextResponder()?.touchesEnded(touches, withEvent: event)
//        } else {
//            super.touchesEnded(touches, withEvent: event)
//        }
//    }

}

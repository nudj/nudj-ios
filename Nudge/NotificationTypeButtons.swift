//
//  NotificationTypeButtons.swift
//  Nudge
//
//  Created by Antonio on 03/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class NotificationTypeButtons: UIButton {

    
    func setupCustomButton(title:String, backgroundColor bgColor:UIColor){
        
        self.frame = CGRectMake(0, 0, 110, 25);
        self.backgroundColor = bgColor;
        self.titleLabel?.textColor = UIColor.whiteColor();
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16);
        self.titleLabel?.text = title;
        
    }

}

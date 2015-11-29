//
//  ChatDropDownView.swift
//  Nudj
//
//  Created by Antonio on 25/06/2015.
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class ChatDropDownView: UIView {
    
    func initWithFrame(){
    
    self = super.frame = CGRectMake(0, 0, 320, 50)

    if (self) {
    
    //creating the view and it's label
    self.userInteractionEnabled = FALSE ;
    UILabel *contentText = [[UILabel alloc] initWithFrame:frame];
    contentText.font = [UIFont fontWithName:@"Helvetica" size:12];
    contentText.textColor = [UIColor whiteColor];
    contentText.textAlignment = NSTextAlignmentCenter;
    contentText.text = @"No Internet Connection";
    contentText.backgroundColor= [DOPPELS_COLOR colorWithAlphaComponent:0.8];
    
    createdFrame = frame;
    isAnimating = NO;
    
    [self setAlpha:0];
    [self addSubview:contentText];
    
    }
    return self;
    }

}

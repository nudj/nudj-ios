//
//  NoContentPlaceHolder.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class NoContentPlaceHolder: UIImageView {

    func createNoContentPlaceHolder(view :UIView, imageTitle:String) -> NoContentPlaceHolder{
        // TODO: magic numbers
        self.frame = CGRectMake((view.frame.size.width/2) - 200/2 , (view.frame.size.height/2) - 149/2, 200,149)
        self.image = UIImage(named: imageTitle)
        self.hidden = true
        
        return self
    }
    
    func showPlaceholder(){
        self.hidden = false
    }
    
    func hidePlaceholder(){
        self.hidden = true
    }
}

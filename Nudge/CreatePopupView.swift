//
//  CreatePopupView.swift
//  Nudge
//
//  Created by Antonio on 01/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import Foundation

protocol CreatePopupViewDelegate {
    
    func dismissPopUp()
    
}

class CreatePopupView: UIView {
    var delegate : CreatePopupViewDelegate?
    var blackBackground : UIView?;
    var whitepopupbox : UIView?;
    var contentImage :UIImageView?;

    
    init(x:CGFloat, yCordinate y:CGFloat, width w:CGFloat, height h:CGFloat, imageName i:String){
    
        self.frame = CGRectMake(x, y, w, h);
        
        self.blackBackground? = UIView(frame: CGRectMake(x, y, w, h));
        self.blackBackground?.backgroundColor = UIColor.blackColor();
        self.blackBackground?.alpha = 0.7;
        self.blackBackground?.userInteractionEnabled = true;
        self.addSubview(self.blackBackground!);
        
        var gesture :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"dismissPopup");
        self.blackBackground?.addGestureRecognizer(gesture)
        
        self.whitepopupbox? = UIView(frame: CGRectMake((w - 250) / 2 , (y - 250) / 2 , 250, 250))
        self.whitepopupbox?.backgroundColor = UIColor.whiteColor();
        self.whitepopupbox?.layer.cornerRadius = 5;
        self.whitepopupbox?.layer.masksToBounds = true;
        
        var gestureTwo :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"dismissPopup");
        self.whitepopupbox?.addGestureRecognizer(gestureTwo)
        
        self.contentImage? = UIImageView(frame: CGRectMake(4 , 22 , 242, 205))
        self.contentImage?.image = UIImage(named:i)
        
        self.whitepopupbox?.addSubview(self.contentImage!)
        self.addSubview(self.whitepopupbox!);

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismissPopup(){
    
    delegate?.dismissPopUp()
    
    }
    
    func createPopup() -> UIView{
        
        return self;
        
    }
}

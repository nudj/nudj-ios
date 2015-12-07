//
//  CreatePopupView.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
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
    var label :UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(x:CGFloat, yCordinate y:CGFloat, width w:CGFloat, height h:CGFloat, imageName i:String, withText:Bool){
        // TODO: magic numbers
        super.init(frame: CGRect(x: x, y: y, width: w, height: h))
        
        self.blackBackground = UIView(frame: CGRectMake(x, y, w, h));
        self.blackBackground!.backgroundColor = UIColor.blackColor();
        self.blackBackground!.alpha = 0.7;
        self.blackBackground!.userInteractionEnabled = true;
        self.addSubview(self.blackBackground!);
        
        let gesture :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"dismissPopup");
        self.blackBackground!.addGestureRecognizer(gesture)
        
        // TODO: magic numbers
        self.whitepopupbox = UIView(frame: CGRectMake((w - 250) / 2 , (h - 250) / 2 , 250, 250))
        self.whitepopupbox!.backgroundColor = UIColor.whiteColor();
        self.whitepopupbox!.layer.cornerRadius = 5;
        self.whitepopupbox!.layer.masksToBounds = true;
        self.whitepopupbox!.userInteractionEnabled = true;
        
        let gestureTwo :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"dismissPopup");
        self.whitepopupbox!.addGestureRecognizer(gestureTwo)
        
        if(withText){
            // TODO: magic numbers
            self.contentImage = UIImageView(frame: CGRectMake((self.whitepopupbox!.frame.size.width - 88)/2 , 22 , 88, 88))
            self.contentImage!.image = UIImage(named:i)
            
            self.label = UILabel(frame: CGRectMake(10, self.contentImage!.frame.origin.y + self.contentImage!.frame.size.height + 10, self.whitepopupbox!.frame.size.width-20, 80))
            self.label!.font = UIFont(name: "HelveticaNeue", size: 22)
            self.label!.textAlignment = NSTextAlignment.Center;
            self.label!.textColor = UIColor(red: 0/255, green: 161/255, blue: 135/255, alpha: 1)
            self.label!.numberOfLines = 3;
            
            self.whitepopupbox!.addSubview(self.contentImage!)
            self.whitepopupbox!.addSubview(self.label!)
        } else {
            self.contentImage = UIImageView(frame: CGRectMake(4 , 22 , 242, 205))
            self.contentImage!.image = UIImage(named:i)
            self.whitepopupbox!.addSubview(self.contentImage!)
        }
        self.addSubview(self.whitepopupbox!);
        
        UIView.animateWithDuration(30, delay: 30, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            //self.blurBg.alpha = 1
            }, completion: { 
                _ in
                //self.hidden = true
                //self.dismissPopup()
        })
    }
    
    func bodyText(s:String){
        self.label!.text = s;
        self.label!.numberOfLines = 0
        self.label!.adjustsFontSizeToFitWidth = true
        self.label!.minimumScaleFactor = 0.2
    }
    
    func dismissPopup(){
        delegate?.dismissPopUp()
    }
}

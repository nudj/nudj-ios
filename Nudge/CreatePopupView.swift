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
    var labl :UILabel?
    
    init(x:CGFloat, yCordinate y:CGFloat, width w:CGFloat, height h:CGFloat, imageName i:String, withText wt:Bool){
        super.init(frame: CGRect(x: x, y: y, width: w, height: h))
        
        self.blackBackground = UIView(frame: CGRectMake(x, y, w, h));
        self.blackBackground!.backgroundColor = UIColor.blackColor();
        self.blackBackground!.alpha = 0.7;
        self.blackBackground!.userInteractionEnabled = true;
        self.addSubview(self.blackBackground!);
        
        var gesture :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"dismissPopup");
        self.blackBackground!.addGestureRecognizer(gesture)
        
        self.whitepopupbox = UIView(frame: CGRectMake((w - 250) / 2 , (h - 250) / 2 , 250, 250))
        self.whitepopupbox!.backgroundColor = UIColor.whiteColor();
        self.whitepopupbox!.layer.cornerRadius = 5;
        self.whitepopupbox!.layer.masksToBounds = true;
        self.whitepopupbox!.userInteractionEnabled = true;

        
        var gestureTwo :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"dismissPopup");
        self.whitepopupbox!.addGestureRecognizer(gestureTwo)
        
        if(wt == true){
        
            self.contentImage = UIImageView(frame: CGRectMake((self.whitepopupbox!.frame.size.width - 88)/2 , 22 , 88, 88))
            self.contentImage!.image = UIImage(named:i)
            
            labl = UILabel(frame: CGRectMake(10, self.contentImage!.frame.origin.y + self.contentImage!.frame.size.height + 10, self.whitepopupbox!.frame.size.width-10, 60))
            labl!.font = UIFont(name: "HelveticaNeue", size: 14)
            labl!.textAlignment = NSTextAlignment.Center;
            labl!.textColor = UIColor(red: 0/255, green: 161/255, blue: 135/255, alpha: 1)
            labl!.numberOfLines = 0;
            
            self.whitepopupbox!.addSubview(self.contentImage!)
            self.whitepopupbox!.addSubview(labl!)
            
        }else{
        
            self.contentImage = UIImageView(frame: CGRectMake(4 , 22 , 242, 205))
            self.contentImage!.image = UIImage(named:i)
            self.whitepopupbox!.addSubview(self.contentImage!)
            
        }
        self.addSubview(self.whitepopupbox!);
        

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bodyText(s:String){
        
        self.labl!.text = s;
    }
    
    func dismissPopup(){
    
    delegate?.dismissPopUp()
    
    }
    
}

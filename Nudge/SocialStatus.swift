//
//  SocialStatus.swift
//  Nudge
//
//  Created by Antonio on 30/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

protocol SocialStatusDelegate {
    
    func didTap(statusIdentifier:String, parent:SocialStatus)
    
}

class SocialStatus: UIImageView {
    
    var delegate : SocialStatusDelegate?
    var currentStatus:Bool?
    var statusIdentifier:String?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(status:Bool, and statusID:String){
        if(status){
            
            super.init(frame: CGRectMake(0, 0, 118, 24))
            self.image = UIImage(named: "connected")
            
        }else{
            
            super.init(frame: CGRectMake(0, 0, 144, 24))
            self.image = UIImage(named: "not_connected")
            
        }
        
        self.currentStatus = status
        self.statusIdentifier = statusID
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        self.userInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func loadStatusContent(status:Bool){
        
        if(status){
            
            self.frame = CGRectMake(0, 0, 118, 24)
            self.image = UIImage(named: "connected")
            
        }else{
           
            self.frame = CGRectMake(0, 0, 144, 24)
            self.image = UIImage(named: "not_connected")
            
        }
        
        self.currentStatus = status

        
    }
    
    func updateStatus(){
        
        if(self.currentStatus != nil){
            
            self.loadStatusContent(!self.currentStatus!)
            
        }
    }
    
    
    func imageTapped(img: AnyObject)
    {
        delegate?.didTap(self.statusIdentifier!, parent: self)
        
    }
        
}


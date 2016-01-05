//
//  SocialStatus.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

protocol SocialStatusDelegate {
    func didTap(statusIdentifier:String, parent:SocialStatus)
}

class SocialStatus: UIImageView {
    
    var delegate : SocialStatusDelegate?
    var connected:Bool = false
    var statusIdentifier:String = ""

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(connected:Bool, and statusID:String) {
        self.connected = connected
        self.statusIdentifier = statusID
        
        if(connected){
            // TODO: magic numbers
            super.init(frame: CGRectMake(0, 0, 118, 24))
            self.image = UIImage(named: "connected")
        }else{
            super.init(frame: CGRectMake(0, 0, 144, 24))
            self.image = UIImage(named: "not_connected")
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        self.userInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func loadStatusContent(connected:Bool) {
        if(connected){
            // TODO: magic numbers
            self.frame = CGRectMake(0, 0, 118, 24)
            self.image = UIImage(named: "connected")
        } else {
            self.frame = CGRectMake(0, 0, 144, 24)
            self.image = UIImage(named: "not_connected")
        }
        self.connected = connected
    }
    
    func toggleConnected() {
        self.loadStatusContent(!self.connected)
    }
        
    func imageTapped(img: AnyObject) {
        delegate?.didTap(self.statusIdentifier, parent: self)        
    }
}

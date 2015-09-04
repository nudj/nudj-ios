//
//  MixPanelHandler.swift
//  Nudge
//
//  Created by Antonio on 20/08/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import Mixpanel

class MixPanelHandler: NSObject {

    static func sendData(title:String){
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mixpanel = Mixpanel.sharedInstance()
        var username = "unavailable"
        var userId = "unavailable"
        
        if let user = appdelegate.user {
        
            if user.name != nil {
                username = user.name!
            }
            
            if user.id != nil{
                userId = "\(user.id!)"
            }
            
        }
        
        
        mixpanel.track(title, properties: ["name":username,"id":userId])
    }
    
    
    static func startEventTracking(title:String){
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.timeEvent(title)
        
    }
    
    static func stopEventTracking(title:String){
    
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track(title)
    }
    
}
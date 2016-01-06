//
//  MixPanelHandler.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import Mixpanel

class MixPanelHandler: NSObject {
    static func sendData(title:String) {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mixpanel = Mixpanel.sharedInstance()
        let username = appdelegate.user.name ?? "unavailable"
        let userId = appdelegate.user.id ?? 0
        mixpanel.track(title, properties: ["name": username, "id": userId])
    }
    
    static func startEventTracking(title:String){
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.timeEvent(title)
    }
    
    static func stopEventTracking(title:String){
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track(title)
    }
    
}

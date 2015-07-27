//
//  Notification.swift
//  Nudge
//
//  Created by Lachezar Todorov on 16.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum NotificationType:Int {
    case AskToRefer = 1
    case AppApplication = 2
    case WebApplication = 3
    case MatchingContact = 4
    case AppApplicationWithNoReferral = 5;
    case WebApplicationWithNoReferral = 6;
}

class Notification {
    
    
    var notificationId:String?
    var notificationType:NotificationType?
    var notificationReadStatus:Bool?
    var notificationTime:Double?
    var notificationMessage:String?
    
    var jobID:String?
    var jobMessage:String?
    var jobTitle:String?
    var jobBonus:String?
    
    var employerName:String?
    
    var senderId:String?
    var senderName:String?
    var senderImage:String?
    
    static func createFromJSON(data:JSON) -> Notification? {
        var type = NotificationType(rawValue: data["type"].stringValue.toInt()!)
        
        if(type == nil){
            return nil
        }
        
        var obj = Notification()
    
        obj.senderImage = data["sender"]["image"]["profile"].stringValue
        obj.senderId = data["sender"]["id"].stringValue
        obj.senderName = data["sender"]["name"].stringValue
        
        obj.employerName = data["meta"]["employer"].stringValue
        
        obj.jobBonus = data["meta"]["job_bonus"].stringValue
        obj.jobMessage = data["meta"]["message"].stringValue
        obj.jobID = data["meta"]["job_id"].stringValue
        obj.jobTitle = data["meta"]["job_title"].stringValue
    
        obj.notificationReadStatus = data["read"].boolValue
        obj.notificationTime = data["created"].doubleValue
        obj.notificationMessage = data["message"].stringValue
        obj.notificationId = data["id"].stringValue
        
        obj.notificationType = type
        
        return obj

    }

}
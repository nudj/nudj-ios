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
    case AskToRefer = 1 // username: can you help me with blah blah blah
    case AppApplication = 2 // username referred by user is interested blah blah blah
    case WebApplication = 3 // username referred by user is interested blah blah blah
    case MatchingContact = 4 // username : might be a good match for
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
    
    static func createFromJSON(data:JSON) -> Notification {
        var obj = Notification()
        
        obj.senderImage = data["sender"]["image"]["profile"].stringValue
        obj.senderId = data["sender"]["id"].stringValue
        obj.senderName = data["sender"]["name"].stringValue
        
        obj.employerName = data["meta"][""].stringValue
        
        obj.jobBonus = data["meta"]["job_bonus"].stringValue
        obj.jobMessage = data["meta"]["message"].stringValue
        obj.jobID = data["meta"]["job_id"].stringValue
        obj.jobTitle = data["meta"]["job_title"].stringValue
        
        obj.notificationType = NotificationType(rawValue: data["type"].stringValue.toInt()!)
        obj.notificationReadStatus = data["read"].boolValue
        obj.notificationTime = data["created"].doubleValue
        obj.notificationMessage = data["message"].stringValue
        obj.notificationId = data["id"].stringValue
        
        return obj

    }

}
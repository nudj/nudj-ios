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
    case NewApplication = 2
    case WebApplication = 3
    case MatchingContact = 4
}

class Notification {
    
    var profileImage:String?
    var notificationId:String?
    var notificationType:NotificationType?
    var jobID:String?
    var jobMessage:String?
    var employerName:String?
    var senderId:String?
    var senderName:String?
    var bonus:String?
    var readStatus:Bool?
    var time:String?
    
    static func createFromJSON(data:JSON) -> Notification {
        var obj = Notification()
        
        obj.profileImage = data["sender"]["image"]["profile"].stringValue
        obj.notificationId = data["id"].stringValue
        obj.jobMessage = data["meta"]["message"].stringValue
        obj.jobID = data["meta"]["job_id"].stringValue
        obj.senderId = data["sender"]["id"].stringValue
        obj.senderName = data["sender"]["name"].stringValue
        obj.notificationType = NotificationType(rawValue: data["type"].stringValue.toInt()!)
        obj.readStatus = data["read"].boolValue
        
        return obj

    }

}
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
    var senderPhoneNumber:String?
    
    var chatId:String?
    
    static func createFromJSON(data:JSON) -> Notification? {
        guard let rawType = Int(data["type"].stringValue) else {
            return nil
        }
        let type = NotificationType(rawValue: rawType)
        let obj = Notification()
    
        obj.senderImage = data["sender"]["image"]["profile"].stringValue
        obj.senderId = data["sender"]["id"].stringValue
        obj.senderName = data["sender"]["name"].stringValue
        obj.senderPhoneNumber = data["meta"]["phone"].stringValue
        
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
        
        obj.chatId =  data["meta"]["chat_id"].stringValue
        
        return obj
    }
}

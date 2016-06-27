//
//  Notification.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import SwiftyJSON

enum NotificationType:Int {
    // TODO: see if we can do without the raw int values
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
    
    init?(json: JSON) {
        guard let rawType = Int(json["type"].stringValue) else {
            return nil
        }
        let type = NotificationType(rawValue: rawType)

        // TODO: API strings
        let sender = json["sender"]
        let metadata = json["meta"]
        senderImage = sender["image"]["profile"].stringValue
        senderId = sender["id"].stringValue
        senderName = sender["name"].stringValue
        senderPhoneNumber = metadata["phone"].stringValue
        
        employerName = metadata["employer"].stringValue
        
        jobBonus = metadata["job_bonus"].stringValue
        jobMessage = metadata["message"].stringValue
        jobID = metadata["job_id"].stringValue
        jobTitle = metadata["job_title"].stringValue
    
        notificationReadStatus = json["read"].boolValue
        notificationTime = json["created"].doubleValue
        notificationMessage = json["message"].stringValue
        notificationId = json["id"].stringValue
        
        notificationType = type
        
        chatId =  metadata["chat_id"].stringValue
    }
}

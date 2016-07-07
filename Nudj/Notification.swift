
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
    var notificationId: String
    var notificationType: NotificationType
    var notificationReadStatus: Bool
    var notificationTime: Double
    var notificationMessage: String
    
    var jobID: Int
    var jobMessage: String
    var jobTitle: String
    var jobBonus: String
    
    var employerName: String
    
    var senderId: Int
    var senderName: String
    var senderImage: String
    var senderPhoneNumber: String
    
    var chatId: Int
    
    init?(json: JSON) {
        guard let rawType = Int(json["type"].stringValue) else {
            return nil
        }
        guard let type = NotificationType(rawValue: rawType) else {
            return nil
        }

        // TODO: API strings
        let sender = json["sender"]
        let metadata = json["meta"]
        senderImage = sender["image"]["profile"].stringValue
        senderId = sender["id"].intValue
        senderName = sender["name"].stringValue
        senderPhoneNumber = metadata["phone"].stringValue
        
        employerName = metadata["employer"].stringValue
        
        jobBonus = metadata["job_bonus"].stringValue
        jobMessage = metadata["message"].stringValue
        jobID = metadata["job_id"].intValue
        jobTitle = metadata["job_title"].stringValue
        
        let bonusAmount = metadata["job_bonus"].intValue
        let bonusCurrency = metadata["job_bonus_currency"].string ?? ""
        
        let job = JobModel(title: jobTitle, description: "", salaryFreeText: "", company: employerName, location: "", bonusAmount: bonusAmount, bonusCurrency: bonusCurrency, active: true, skills: [])
        jobBonus = job.formattedBonus 
    
        notificationReadStatus = json["read"].boolValue
        notificationTime = json["created"].doubleValue
        notificationMessage = json["message"].stringValue
        notificationId = json["id"].stringValue
        
        notificationType = type
        
        chatId =  metadata["chat_id"].intValue
    }
}

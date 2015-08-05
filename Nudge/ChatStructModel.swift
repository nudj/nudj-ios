//
//  ChatStructModel.swift
//  Nudge
//
//  Created by Antonio on 05/08/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class ChatStructModel: NSObject {
   
    var chatId:String?
    var time:String?
    var timeinRawForm:NSDate?
    var image:String?
    var isRead:Bool?
    var isNew:Bool?
    var title:String?
    var participantName:String?
    var participantsID:String?
    var jobID:String?
    var job:JSON?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()
   
    func createData(json:JSON) -> ChatStructModel{
        
        var chat = ChatStructModel()
        
        chat.chatId = json["id"].stringValue
        chat.title = json["job"]["title"].stringValue
        chat.jobID = json["job"]["id"].stringValue
        chat.job = json["job"]
        
        if let outData = NSUserDefaults.standardUserDefaults().dataForKey(chat.chatId!){
        
            self.retrieveStoredContent(chat)
            
        }else{
            
            //A saved object hasnt been created for this chat because its an old one
            //So create one with these defaul properties
            
            var dict = ["isNew":false, "isRead":true]
            var data = NSKeyedArchiver.archivedDataWithRootObject(dict)
            defaults.setObject(data, forKey:chat.chatId!)
            defaults.synchronize()
            
            self.retrieveStoredContent(chat)
            
        }
        
        let user = json["participants"][0]["id"].intValue == appDelegate.user!.id ? json["participants"][1] : json["participants"][0]
        chat.participantName =  user["name"].stringValue
        chat.participantsID = user["id"].stringValue
        chat.image = user["image"]["profile"].stringValue
        
        return chat
        
    }
    
    
    func markAsRead(){
    
        //Mark as read
        if(self.isRead != nil && self.isRead! == false){
            
            self.isRead = true
            var dict = ["isNew":false, "isRead":true]
            var data = NSKeyedArchiver.archivedDataWithRootObject(dict)
            defaults.setObject(data, forKey:self.chatId!)
            defaults.synchronize()
            println("Marked as read")
            
        }else{
            
        }
        
    }
    
    func retrieveStoredContent(chat:ChatStructModel){
        
        let outData = NSUserDefaults.standardUserDefaults().dataForKey(chat.chatId!)
        var dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData!) as! NSDictionary
        
        if dict.count > 0 {
            
            println("has stored content \(dict)")
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "d/M/yy - H:mm"
            
            //Get time of last message
            let arr = appDelegate.chatInst!.listOfActiveChatRooms[chat.chatId!]!.retrieveStoredChats()
            if arr.count != 0 {
                
                let time = arr.lastObject as! JSQMessage
                chat.time  = dateFormatter.stringFromDate(time.date)
                chat.timeinRawForm = time.date
                
            }else{
                
                //TODO: Fix this
                //default to right now
                chat.time  = dateFormatter.stringFromDate(NSDate())
                chat.timeinRawForm = NSDate()
                
            }
            
            chat.isRead = dict["isRead"] as? Bool
            chat.isNew = dict["isNew"]as? Bool
            
        }
        
    }
    
}

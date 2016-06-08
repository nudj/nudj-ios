//
//  AppChatDelegate.swift
//  Nudj
//
//  Created by Richard Buckle on 02/03/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

class AppChatDelegate: ChatModelsDelegate {
    var chatInst: ChatModels
    
    init(chatInst: ChatModels) {
        self.chatInst = chatInst
    }
    
    func failedToConnect(error: NSError) {
        loggingPrint("\(error.localizedDescription)\n\(error.localizedFailureReason)")
    }

    func receivedUser(content: NSDictionary) {
        // TODO: determine what to do
    }
    
    func receivedMessage(content: JSQMessage, conference: String) {
        //Store message as it's new
        let roomID = self.chatInst.getRoomIdFromJidString(conference)
        
        loggingPrint("Saving new message \(roomID)")
        let defaults = NSUserDefaults.standardUserDefaults()
        if let outData = defaults.dataForKey(roomID) {
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                var diction = dict
                
                //overwrite previous data if it exsists
                diction["isRead"] = false
                let data = NSKeyedArchiver.archivedDataWithRootObject(diction)
                defaults.setObject(data, forKey:roomID)
                defaults.synchronize()
            }
        }
        
        // Update badge
        MainTabBar.postBadgeNotification("1", tabIndex: .Chats)
        
        // reload chat table
        NSNotificationCenter.defaultCenter().postNotificationName(ChatListViewController.Notifications.Refetch.rawValue, object: nil, userInfo:nil)
    }
    
    func isReceivingMessageIndication(user: String) {
        // TODO: determine what to do
    }
}

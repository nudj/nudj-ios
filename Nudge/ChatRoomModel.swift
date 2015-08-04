//
//  ChatRoomModel.swift
//  Nudge
//
//  Created by Antonio on 28/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import Foundation
import CoreData

class ChatRoomModel: NSObject{
    var xmppRoom :XMPPRoom?
    var xmppRoomStorage :XMPPRoomCoreDataStorage?
    var roomID:String?
    
    func prepareChatModel(roomName:String, roomId:String, with xmpp:XMPPStream, delegate:XMPPRoomDelegate) {
        
        self.roomID = roomId
        
        self.xmppRoomStorage = XMPPRoomCoreDataStorage(databaseFilename:"\(roomId).sqlite", storeOptions: nil)
        
        var roomJID = XMPPJID.jidWithString(roomName);
        
        if(roomJID != nil){
        
        self.xmppRoom = XMPPRoom(roomStorage: xmppRoomStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())
        self.xmppRoom!.addDelegate(delegate, delegateQueue: dispatch_get_main_queue())
        self.xmppRoom!.activate(xmpp)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.xmppRoom!.joinRoomUsingNickname("\(appDelegate.user!.id!)@\(appDelegate.chatInst!.chatServer)", history:nil)
        
        }
    }
    
    func retrieveStoredChats() -> NSMutableArray{
        
        if(self.xmppRoomStorage == nil){
            
            return []
            
        }
        
        var moc = self.xmppRoomStorage!.mainThreadManagedObjectContext;
        
        var entityDescription = NSEntityDescription.entityForName("XMPPRoomMessageCoreDataStorageObject", inManagedObjectContext: moc);
        var request = NSFetchRequest();
        request.entity = entityDescription;
        var error: NSError?;
        
        var messages :NSArray = moc.executeFetchRequest(request, error: &error)!;
        
        if(messages.count == 0){
            
            return []
            
        }
        
        var message:XMPPMessageArchiving_Message_CoreDataObject?;
        
        var messageObject = NSMutableArray();
        
        // Retrieve all the messages for the current conversation
        for message in messages {
            
            if (message.nickname() != nil){
                messageObject.addObject(JSQMessage(senderId: message.nickname(), senderDisplayName: message.nickname(), date:message.localTimestamp(), text: message.body()))
            }
        }
        
        return messageObject
    }
    

}

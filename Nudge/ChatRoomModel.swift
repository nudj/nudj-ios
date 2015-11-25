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
    var delegate:XMPPRoomDelegate?
    var otherUserPresence:String?
    var roomID:String?
    
    func prepareChatModel(roomName:String, roomId:String, with xmpp:XMPPStream, delegate:XMPPRoomDelegate) {
        
        self.roomID = roomId
        self.delegate = delegate
        
        self.xmppRoomStorage = XMPPRoomCoreDataStorage(databaseFilename:"\(roomId).sqlite", storeOptions: nil)
        var roomJID = XMPPJID.jidWithString(roomName);
        
        if(roomJID != nil && self.xmppRoomStorage != nil){
        
        print("Preparing to Activating room -> \(roomJID)")
            
        self.xmppRoom = XMPPRoom(roomStorage: self.xmppRoomStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())
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
            
            if (message.nickname() != nil && message.localTimestamp() != nil){
                //handle system message
                var sendersId = ""
                
                if(message.nickname().rangeOfString(":") != nil){
                    let name = split(message.nickname()) {$0 == ":"}
                    sendersId = name[1]
                }else{
                    sendersId = message.nickname()
                }
                
                print("sender -> \(sendersId)")
                messageObject.addObject(JSQMessage(senderId: sendersId, senderDisplayName: sendersId, date:message.localTimestamp(), text: message.body()))
                
            }else{
                
                print("Error getting the Sender of this message or Timestamp")
                
            }
        }
        
        return messageObject
    }
    
    func deleteStoredChats(){

        if(self.xmppRoomStorage == nil){
            
            return
        }
        
        var moc = self.xmppRoomStorage!.mainThreadManagedObjectContext;
        var entityDescription = NSEntityDescription.entityForName("XMPPRoomMessageCoreDataStorageObject", inManagedObjectContext: moc);
        var request = NSFetchRequest();
        request.entity = entityDescription;
        var error: NSError?;
        
        var messages :NSArray = moc.executeFetchRequest(request, error: &error)!;
        if(messages.count == 0){
            
            return
        }
        
        var message:NSManagedObject?
        
        // Retrieve all the messages for the current conversation
        for message in messages {
        
            moc.deleteObject(message as! NSManagedObject)
    
        }
        
        var saveError: NSError?
        moc.save(&saveError)

        print("core storage deleted for id:\(roomID!)")
    }
    
    
    func teminateSession(){
        self.xmppRoom!.leaveRoom()
        self.xmppRoom!.deactivate()
        self.xmppRoom!.removeDelegate(self.delegate)
    }
    
    
    func reconnect(){
        
        /*self.teminateSession()
        
        var roomJID = XMPPJID.jidWithString(roomName);
        print("did generate room jid -> \(roomJID)")
        
        if(roomJID != nil && self.xmppRoomStorage != nil){
            
            self.xmppRoom = XMPPRoom(roomStorage: self.xmppRoomStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())
            self.xmppRoom!.addDelegate(delegate, delegateQueue: dispatch_get_main_queue())
            self.xmppRoom!.activate(xmpp)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            self.xmppRoom!.joinRoomUsingNickname("\(appDelegate.user!.id!)@\(appDelegate.chatInst!.chatServer)", history:nil)
            
        }*/
     
    }

}

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
        let roomJID = XMPPJID.jidWithString(roomName);
        
        if(roomJID != nil && self.xmppRoomStorage != nil){
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
        
        let moc = self.xmppRoomStorage!.mainThreadManagedObjectContext;
        let entityDescription = NSEntityDescription.entityForName("XMPPRoomMessageCoreDataStorageObject", inManagedObjectContext: moc);
        let request = NSFetchRequest();
        request.entity = entityDescription;
        
        do {
            let messages: NSArray = try moc.executeFetchRequest(request);
            if(messages.count == 0) {
                return []
            }
            
            // var message:XMPPMessageArchiving_Message_CoreDataObject?;
            let messageObject = NSMutableArray();
            
            // Retrieve all the messages for the current conversation
            for message in messages {
                if let nickname: String = message.nickname, timestamp = message.localTimestamp() {
                    // handle system message
                    let nicknameParts = nickname.componentsSeparatedByString(":")
                    let sendersId: String
                    switch nicknameParts.count {
                    case 0:
                        sendersId = ""
                        break
                    case 1:
                        sendersId = nickname
                        break
                    default:
                        sendersId = nicknameParts[1]
                        break
                    }
                    messageObject.addObject(JSQMessage(senderId: sendersId, senderDisplayName: sendersId, date: timestamp, text: message.body()))
                } else {
                    // TODO: better error handling
                    loggingPrint("Error getting the Sender or Timestamp of this message")
                }
            }
            
            return messageObject
        }
        catch let error as NSError {
            // TODO: handle the error
            loggingPrint("Error fetching stored chat: \(error)")
            return []
        }
    }
    
    func deleteStoredChats(){
        if(self.xmppRoomStorage == nil){
            return
        }
        
        let moc = self.xmppRoomStorage!.mainThreadManagedObjectContext;
        let entityDescription = NSEntityDescription.entityForName("XMPPRoomMessageCoreDataStorageObject", inManagedObjectContext: moc);
        let request = NSFetchRequest();
        request.entity = entityDescription;
        
        do {
            let messages: NSArray = try moc.executeFetchRequest(request);
            if(messages.count == 0){
                return
            }
            
            // delete all the messages for the current conversation
            for message in messages {
                moc.deleteObject(message as! NSManagedObject)
            }
        }
        catch let error as NSError {
            // TODO: handle the error
            loggingPrint("Error fetching stored chat: \(error)")
            return
        }
        
        do {
            try moc.save()
        }
        catch let error as NSError {
            // TODO: handle the error
            loggingPrint("Error saving core data: \(error)")
        }

        loggingPrint("core storage deleted for id:\(roomID!)")
    }
    
    func teminateSession(){
        self.xmppRoom!.leaveRoom()
        self.xmppRoom!.deactivate()
        self.xmppRoom!.removeDelegate(self.delegate)
    }
    
    func reconnect(){
        // TODO: review this
        /*self.teminateSession()
        
        var roomJID = XMPPJID.jidWithString(roomName);
        loggingPrint("did generate room jid -> \(roomJID)")
        
        if(roomJID != nil && self.xmppRoomStorage != nil){
            
            self.xmppRoom = XMPPRoom(roomStorage: self.xmppRoomStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())
            self.xmppRoom!.addDelegate(delegate, delegateQueue: dispatch_get_main_queue())
            self.xmppRoom!.activate(xmpp)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            self.xmppRoom!.joinRoomUsingNickname("\(appDelegate.user!.id!)@\(appDelegate.chatInst!.chatServer)", history:nil)
            
        }*/
    }

}

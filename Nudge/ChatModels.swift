//
//  ChatModels.swift
//  Nudge
//
//  Created by Antonio on 23/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import SwiftyJSON

protocol ChatModelsDelegate {
    func recievedMessage(content:JSQMessage, conference:String)
    func recievedUser(content:NSDictionary)
    func isRecievingMessageIndication(user:String)
}

class ChatModels: NSObject, XMPPRosterDelegate, XMPPRoomDelegate {
    var delegate : ChatModelsDelegate?
    var chatInformation = [NSManagedObject]();
    
    var jabberUsername:String?;
    var jabberPassword:String?;
    var listOfActiveChatRooms = [String:ChatRoomModel]()
    
    let chatServer = "chat.nudj.co";
    let ConferenceUrl = "@conference.chat.nudj.co";
    let appGlobalDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // XMPP ATTRIBUTES
    var xmppStream : XMPPStream?;
    var xmppReconnect :XMPPReconnect?;
    var xmppRosterStorage :XMPPRosterCoreDataStorage?;
    var xmppRoster :XMPPRoster?;
    var xmppvCardStorage :XMPPvCardCoreDataStorage?;
    var xmppvCardTempModule :XMPPvCardTempModule?;
    var xmppvCardAvatarModule :XMPPvCardAvatarModule?;
    var xmppCapabilitiesStorage :XMPPCapabilitiesCoreDataStorage?;
    var xmppCapabilities :XMPPCapabilities?;
    var xmppMessageArchivingStorage :XMPPMessageArchivingCoreDataStorage?;
    var xmppMessageArchivingModule  :XMPPMessageArchiving?;
    var xmppRoomStorage :XMPPRoomCoreDataStorage?;
    var xmppRoom :XMPPRoom?;
    
    
    override init() {
        super.init();
        self.setupStream()
    }
    
    func setupStream() {
        
        // SET UP ALL XMPP MODULES
        // Setup vCard support
        // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
        // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
        
        xmppStream = XMPPStream();
        
        xmppReconnect = XMPPReconnect();
        xmppRosterStorage = XMPPRosterCoreDataStorage();
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage);
        
        xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance();
        xmppvCardTempModule = XMPPvCardTempModule(withvCardStorage:xmppvCardStorage);
        
        xmppvCardAvatarModule = XMPPvCardAvatarModule(withvCardTempModule:xmppvCardTempModule);
        
        xmppCapabilitiesStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance();
        xmppCapabilities = XMPPCapabilities(capabilitiesStorage: xmppCapabilitiesStorage);
        
        // SET UP ALL XMPP MODULES
        xmppRoster!.autoFetchRoster = true;
        xmppRoster!.autoAcceptKnownPresenceSubscriptionRequests = true;
        
        xmppCapabilities!.autoFetchHashedCapabilities = true;
        xmppCapabilities!.autoFetchNonHashedCapabilities = true;
        
        xmppMessageArchivingStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance();
        xmppMessageArchivingModule = XMPPMessageArchiving(messageArchivingStorage: xmppMessageArchivingStorage);
        xmppMessageArchivingModule!.clientSideMessageArchivingOnly = true;
        
        xmppRoomStorage = XMPPRoomCoreDataStorage.sharedInstance();
        
        // Activate xmpp modules
        xmppReconnect!.activate(xmppStream);
        xmppRoster!.activate(xmppStream);
        xmppvCardTempModule!.activate(xmppStream);
        xmppvCardAvatarModule!.activate(xmppStream);
        xmppCapabilities!.activate(xmppStream);
        xmppMessageArchivingModule!.activate(xmppStream);
        
        xmppStream!.addDelegate(self, delegateQueue: dispatch_get_main_queue());
        xmppRoster!.addDelegate(self, delegateQueue:dispatch_get_main_queue());
        xmppMessageArchivingModule!.addDelegate(self, delegateQueue:dispatch_get_main_queue());
        
        
    }
    
    // MARK: XMPP Dealloc
    
    func teardownStream(){
        
        // REMOVE FROM MEMORY
        xmppStream!.removeDelegate(self);
        xmppRoster!.removeDelegate(self);
        
        xmppReconnect!.deactivate();
        xmppRoster!.deactivate();
        xmppvCardTempModule!.deactivate();
        xmppvCardAvatarModule!.deactivate();
        xmppCapabilities!.deactivate();
        
        xmppStream!.disconnect();
        
        xmppStream = nil;
        xmppReconnect = nil;
        xmppRoster = nil;
        xmppRosterStorage = nil;
        xmppvCardStorage = nil;
        xmppvCardTempModule = nil;
        xmppvCardAvatarModule = nil;
        xmppCapabilities = nil;
        xmppCapabilitiesStorage = nil;
        
    }
    
    // MARK: XMPP methods protocols and configs
    
    func managedObjectContext_roster () -> NSManagedObjectContext! {
        
        return xmppRosterStorage!.mainThreadManagedObjectContext;
        
    }
    
    func managedObjectContext_capabilities () -> NSManagedObjectContext!{
        
        return xmppCapabilitiesStorage!.mainThreadManagedObjectContext;
        
    }
    
    func goOnline()
    {
        
        var presence : XMPPPresence = XMPPPresence()
        xmppStream!.sendElement(presence);
        
    }
    
    func goOffline()
    {
        
        var presence : XMPPPresence = XMPPPresence(type: "unavailable");
        xmppStream!.sendElement(presence);
        
    }
    
    
    func connect() -> Bool{
        
        let prefs = NSUserDefaults.standardUserDefaults();
        
        
        if (!xmppStream!.isDisconnected()) {
            
            self.goOnline();
            
            return true;
            
        }
        
        if (appGlobalDelegate.user == nil){
        
            return false
        
        }
        
        jabberPassword = appGlobalDelegate.user!.token;
        jabberUsername = "\(appGlobalDelegate.user!.id!)@\(chatServer)";
        
        
        println("Connecting to chat server with: \(jabberUsername!) - \(jabberPassword!)");
        
        if ( jabberUsername!.isEmpty || jabberPassword!.isEmpty) {
            
            return false;
            
        }
        
        
        xmppStream!.myJID = XMPPJID.jidWithString(jabberUsername);
        var error: NSError?;
        
        if (!xmppStream!.connectWithTimeout(XMPPStreamTimeoutNone, error: &error)) {
            
            let alertView = UIAlertView(title: "Error", message:"Can't connect to the chat server \(error!.localizedDescription)", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            
            return false;
            
        }
        
        return true;
        
        
        
    }
    
    
    func disconnect(query:Bool){
        let prefs = NSUserDefaults.standardUserDefaults();
        
        // getting the token
        let token = prefs.stringForKey("token");
        
        self.goOffline();
        
        if(query){
            xmppStream!.disconnect();
        }
        
    }
    
    
    func xmppStreamDidConnect(sender :XMPPStream) {
        
        var error : NSError?;
       
        
        if (!self.xmppStream!.authenticateWithPassword(jabberPassword, error: &error))
        {
            println("Error authenticating: \(error)");
        }
        
        
    }
    
    func xmppStreamDidAuthenticate(sender :XMPPStream) {
        
        self.goOnline();
        
        println("CLIENT HAS CONNECTED TO JABBER");
        
        self.requestRooms();
    }
    
    
    func xmppStream(sender:XMPPStream, didNotAuthenticate error:DDXMLElement){
        
        println("Could not authenticate Error \(error)");
        
    }
    
    func xmppStream(sender :XMPPStream, didReceiveMessage message:XMPPMessage) {
        
        var conferenceInvitation = message.elementForName("x", xmlns:"jabber:x:conference")
        
        if(conferenceInvitation != nil){
            
            println("Received conference invite from ->  \(message.fromStr())")
            
            var jid = conferenceInvitation.attributesAsDictionary().valueForKey("jid") as! String
            var chatroom = ChatRoomModel()
            var roomID = split(jid) {$0 == "@"}
            
            //Store new chat
            println("Saving \(roomID[0])")
            let defaults = NSUserDefaults.standardUserDefaults()
            var dict = ["isNew":true, "isRead":false]
            var data = NSKeyedArchiver.archivedDataWithRootObject(dict)
            defaults.setObject(data, forKey:roomID[0])
            defaults.synchronize()
            
            appGlobalDelegate.shouldShowBadge = true;
            
            //terminate room and reconnect
            chatroom.prepareChatModel(jid, roomId: roomID[0], with:self.xmppStream!, delegate:self)
            self.listOfActiveChatRooms[roomID[0]] = chatroom

            /*chatroom.teminateSession()
            
            let delay = 6 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                
                chatroom.prepareChatModel(jid, roomId: roomID[0], with:self.xmppStream!, delegate:self)
                self.listOfActiveChatRooms[roomID[0]] = chatroom
            
            }*/

            
        }else{

            // println("Received something from the messages delegate -> \(message.attributesAsDictionary())")
        
        }
        
        
    }
    
    func xmppStream(sender:XMPPStream, didReceiveIQ iq:XMPPIQ) -> Bool{

        var roster = iq.elementForName("query", xmlns:"jabber:iq:roster")
        var vCard = iq.elementForName("vCard", xmlns:"vcard-temp")
        var conference = iq.elementForName("query", xmlns:"http://jabber.org/protocol/disco#items");
        
        // GET JABBER ROSTER item
        if (roster != nil){
            
            let itemElements = roster.elementsForName("item") as NSArray;
            //  println("Recieved a roster for -> \(itemElements)");

        }else if(vCard != nil){
            
            //  var fullNameQuery = queryElement1.elementForName("from");
            //  println("Recieved a vcard for -> \(vCard)");

        }else if(conference != nil){

            let itemElements = conference.elementsForName("item") as NSArray;
            //  println("Recieved conferences -> \(itemElements)");

            
        }else{
            
            //  println("Recieved something i dont know -> \(iq)");
        }
        
        
        return true
    }

    func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
        
        if(message.hasComposingChatState() == true){
            
            println("should show typing ")
            
        }
        
        if(message.hasPausedChatState()){
            
            println("should stop typing ")
            
        }
        
        println("will do something with chat message")
        
        if message.body() != nil {
            
            var time : NSDate?
            
            if(message.elementsForName("delay").count > 0){
                
                let delay :DDXMLElement = message.elementForName("delay")
                var stringTimeStamp = delay.attributeStringValueForName("stamp")
                
                stringTimeStamp = stringTimeStamp.stringByReplacingOccurrencesOfString("T", withString: " ")
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSxxx";
                time = dateFormatter.dateFromString(stringTimeStamp)
                
                if(time == nil){
                    time = NSDate()
                }
                
            }else{
                
                time = NSDate();
                
                appGlobalDelegate.shouldShowBadge = true;
                
            }
            
            var jsqMessage = JSQMessage(senderId: message.from().resource, senderDisplayName: message.from().resource, date:time!, text: message.body())
            delegate?.recievedMessage(jsqMessage, conference: sender.roomJID.bare())
        }

    }
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        
        println("XMPPROOM JOINED)")
        
        
    }
    
    func xmppRoomDidCreate(sender: XMPPRoom!) {
        
       println("XMPPROOM CREATED -> \(sender.roomJID)")

    }
    
    
    
    // MARK: Custom chat room methods
    
    
    func requestRooms(){
        
        let params = [String: AnyObject]()
        
        API.sharedInstance.request(Alamofire.Method.GET, path: "chat", params: params, closure:{
            (json: JSON) in
            
            if (json["status"].boolValue != true && json["data"] == nil) {
                
                println("ChatRoom Request Error -> \(json)")
                
            }
            else
            {
                self.listOfActiveChatRooms.removeAll(keepCapacity: false)
                for (id, obj) in json["data"]{
                    let data = obj["id"].string
                   
                    println("Active chatrooms -> \(data!)\(self.ConferenceUrl)")
                    var chatroom = ChatRoomModel()
                    chatroom.prepareChatModel("\(data!)\(self.ConferenceUrl)", roomId: data!, with:self.xmppStream!, delegate:self)
                    self.listOfActiveChatRooms[data!] = chatroom
                }
             
                
            }
            
            }, errorHandler: nil)
        
    }


}
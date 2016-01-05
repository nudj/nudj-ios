//
//  ChatModels.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import CoreData
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
    
    lazy var dateFormatter: NSDateFormatter = { 
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSxxx";
        return dateFormatter
    }()
    
    // TODO: API strings
    let chatServer = "chat.nudj.co";
    let ConferenceUrl = "@conference.chat.nudj.co";
    // TODO: remove singleton
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
        let presence : XMPPPresence = XMPPPresence()
        xmppStream!.sendElement(presence);
    }
    
    func goOffline()
    {
        let presence : XMPPPresence = XMPPPresence(type: "unavailable");
        xmppStream!.sendElement(presence);
    }
    
    func connect(inViewController viewController: UIViewController) -> Bool {
        if (!xmppStream!.isDisconnected()) {
            self.goOnline();
            return true;
        }
        
        guard let user = appGlobalDelegate.user else {
            return false
        }
        
        guard let id = user.id else {
            return false
        }
        
        jabberPassword = user.token;
        jabberUsername = "\(id)@\(chatServer)";
        if ( jabberUsername!.isEmpty || jabberPassword!.isEmpty) {
            return false;
        }
        
        xmppStream!.myJID = XMPPJID.jidWithString(jabberUsername);
        do {
            try xmppStream!.connectWithTimeout(XMPPStreamTimeoutNone)
            return true;
        }
        catch let error as NSError {
            let title = Localizations.Chat.Connection.Error.Title
            let message = Localizations.Chat.Connection.Error.Body.Format(error.localizedDescription)
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Default, handler: nil)
            alert.addAction(defaultAction)
            alert.preferredAction = defaultAction
            viewController.presentViewController(alert, animated: true, completion: nil)
            return false;
        }
    }
    
    func disconnect(query:Bool){
        self.goOffline();
        if(query){
            xmppStream!.disconnect();
        }
    }
    
    func xmppStreamDidConnect(sender :XMPPStream) {
        do{
            try self.xmppStream!.authenticateWithPassword(jabberPassword)
        }
        catch let error as NSError {
            // TODO: better error handling
            loggingPrint("Error authenticating: \(error)");
        }
    }
    
    func xmppStreamDidAuthenticate(sender :XMPPStream) {
        self.goOnline();
        loggingPrint("CLIENT HAS CONNECTED TO JABBER");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            self.requestRooms();
        })
    }
    
    
    func xmppStream(sender:XMPPStream, didNotAuthenticate error:DDXMLElement){
        // TODO: better error handling
        loggingPrint("Could not authenticate Error \(error)");
    }
    
    func xmppStream(sender :XMPPStream, didReceiveMessage message:XMPPMessage) {
        let conferenceInvitation = message.elementForName("x", xmlns:"jabber:x:conference")
        
        if(conferenceInvitation != nil){
            let jid = conferenceInvitation.attributesAsDictionary().valueForKey("jid") as! String
            let chatroom = ChatRoomModel()
            let roomID = self.getRoomIdFromJid(jid)
            
            //Store new chat
            let defaults = NSUserDefaults.standardUserDefaults()
            let dict = ["isNew":true, "isRead":false]
            let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
            defaults.setObject(data, forKey:roomID)
            defaults.synchronize()
            
            appGlobalDelegate.shouldShowBadge = true;
            
            //terminate room and reconnect
            chatroom.prepareChatModel(jid, roomId: roomID, with:self.xmppStream!, delegate:self)
            self.listOfActiveChatRooms[roomID] = chatroom
        } else {
            // TODO: better error handling
            // loggingPrint("Received something from the messages delegate -> \(message.attributesAsDictionary())")
        }
    }
    
    func xmppStream(sender:XMPPStream, didReceiveIQ iq:XMPPIQ) -> Bool{

        let roster = iq.elementForName("query", xmlns:"jabber:iq:roster")
        let vCard = iq.elementForName("vCard", xmlns:"vcard-temp")
        let conference = iq.elementForName("query", xmlns:"http://jabber.org/protocol/disco#items");
        
        // GET JABBER ROSTER item
        if (roster != nil){
            // let itemElements = roster.elementsForName("item") as NSArray;
            //  loggingPrint("Recieved a roster for -> \(itemElements)");
        }else if(vCard != nil){
            //  let fullNameQuery = queryElement1.elementForName("from");
            //  loggingPrint("Recieved a vcard for -> \(vCard)");
        }else if(conference != nil){
            // let itemElements = conference.elementsForName("item") as NSArray;
            //  loggingPrint("Recieved conferences -> \(itemElements)");
        }else{
            // TODO: better error handling
            //   loggingPrint("Recieved something i dont know -> \(iq)");
        }
        return true
    }

    func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
    //Typing indicator
    //        if(message.hasComposingChatState() == true){
    //            
    //            loggingPrint("should show typing ")
    //            
    //        }
    //        
    //        if(message.hasPausedChatState()){
    //            
    //            loggingPrint("should stop typing ")
    //            
    //        }
        
        if message.body() != nil {
            var time : NSDate?
            
            if(message.elementsForName("delay").count > 0){
                let delay :DDXMLElement = message.elementForName("delay")
                var stringTimeStamp = delay.attributeStringValueForName("stamp")
                
                stringTimeStamp = stringTimeStamp.stringByReplacingOccurrencesOfString("T", withString: " ")
                time = self.dateFormatter.dateFromString(stringTimeStamp)
                if(time == nil){
                    time = NSDate()
                }
            } else {
                time = NSDate();
                appGlobalDelegate.shouldShowBadge = true;
            }
            
            if let senderStr = message.from().resource {
                //handle system message
                var sendersId = ""
                let components = senderStr.componentsSeparatedByString(":")
                if(components.count > 1){
                    sendersId = components[1]
                } else {
                    sendersId = senderStr
                }
        
                let jsqMessage = JSQMessage(senderId: sendersId, senderDisplayName: sendersId, date:time!, text: message.body())
                delegate?.recievedMessage(jsqMessage, conference: sender.roomJID.bare())
            } else {
                // TODO: better error handling
                loggingPrint("Error getting sender of this message")
            }
        }
    }
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        loggingPrint("XMPPROOM JOINED ->  \(sender.roomJID))")
    }
    
    func xmppRoomDidCreate(sender: XMPPRoom!) {
       loggingPrint("XMPPROOM CREATED -> \(sender.roomJID)")
    }
    
    func xmppRoomDidLeave(sender: XMPPRoom!) {
        loggingPrint("XMPPROOM LEFT -> \(sender.roomJID.description)")
        let roomID = self.getRoomIdFromJid(sender.roomJID.description)
        
        if let chatRoom = appGlobalDelegate.chatInst!.listOfActiveChatRooms[roomID] {
            chatRoom.teminateSession()
            appGlobalDelegate.chatInst!.listOfActiveChatRooms.removeValueForKey(roomID)
            loggingPrint("removed from list")
        }
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        loggingPrint("occupantDidJoinroom \(presence.type()) \(occupantJID.description)")
        let roomID = self.getRoomIdFromJid(sender.roomJID.description)
        if let chatRoom = appGlobalDelegate.chatInst!.listOfActiveChatRooms[roomID] {
            chatRoom.otherUserPresence = presence.type()
        }
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidUpdate occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        loggingPrint("occupantDidUpdateroom \(presence.type()) \(occupantJID.description)")
        let roomID = self.getRoomIdFromJid(sender.roomJID.description)
        if let chatRoom = appGlobalDelegate.chatInst!.listOfActiveChatRooms[roomID] {
            chatRoom.otherUserPresence = presence.type()
        }
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidLeave occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        loggingPrint("occupantDidLeaveroom \(presence.type()) \(occupantJID.description)")
        let roomID = self.getRoomIdFromJid(sender.roomJID.description)
        if let chatRoom = appGlobalDelegate.chatInst!.listOfActiveChatRooms[roomID] {
            chatRoom.otherUserPresence = presence.type()
        }
    }
    
    func xmppRoomDidDestroy(sender: XMPPRoom!) {
        loggingPrint("XMPPROOM DESTROYED -> \(sender.roomJID)")
    }
    
    // MARK: Custom chat room methods
    
    func requestRooms(){
        let params = [String: AnyObject]()
        API.sharedInstance.request(API.Method.GET, path: "chat/all?&limit=100", params: params, closure:{
            (json: JSON) in
            if (json["status"].boolValue != true && json["data"] == nil) {
                // TODO: better error handling
                loggingPrint("ChatRoom Request Error -> \(json)")
            } else {
                self.listOfActiveChatRooms.removeAll(keepCapacity: false)
                for (_, obj) in json["data"]{
                    let data = obj["id"].string
                    let chatroom = ChatRoomModel()
                    chatroom.prepareChatModel("\(data!)\(self.ConferenceUrl)", roomId: data!, with:self.xmppStream!, delegate:self)
                    self.listOfActiveChatRooms[data!] = chatroom
                }
            }
            
            }, errorHandler: nil)
    }
    
    func getRoomIdFromJid(jid:String) -> String{
        let components = jid.componentsSeparatedByString("@")
        return components[0]
    }
}

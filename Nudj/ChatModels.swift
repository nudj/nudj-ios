//
//  ChatModels.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

protocol ChatModelsDelegate: class {
    func failedToConnect(error: NSError)
    func receivedMessage(content:JSQMessage, conference:String)
    func receivedUser(content:NSDictionary)
    func isReceivingMessageIndication(user:String)
}

class ChatModels: NSObject, XMPPStreamDelegate, XMPPRosterDelegate, XMPPRoomDelegate {
    weak var delegate : ChatModelsDelegate?
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
        let api = API()
        xmppStream?.hostName = api.server.chatHostname
        xmppStream?.autoStartTLS = true
        
        xmppReconnect = XMPPReconnect();
        xmppRosterStorage = XMPPRosterCoreDataStorage();
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage);
        
        xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance();
        xmppvCardTempModule = XMPPvCardTempModule(vCardStorage:xmppvCardStorage);
        
        xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule:xmppvCardTempModule);
        
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
    
    func connect(user: UserModel, inViewController viewController: UIViewController) -> Bool {
        if (!xmppStream!.isDisconnected()) {
            self.goOnline()
            return true;
        }
        
        guard let id = user.id else {
            return false
        }
        
        jabberPassword = user.token
        let api = API()
        let hostname = api.server.chatHostname
        jabberUsername = "\(id)@\(hostname)"
        if ( jabberUsername!.isEmpty || jabberPassword!.isEmpty) {
            return false;
        }
        
        xmppStream!.myJID = XMPPJID.jidWithString(jabberUsername);
        do {
            try xmppStream!.connectWithTimeout(XMPPStreamTimeoutNone)
            return true
        }
        catch let error as NSError {
            delegate?.failedToConnect(error)
            return false
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
            delegate?.failedToConnect(error)
        }
    }
    
    func xmppStreamDidAuthenticate(sender :XMPPStream) {
        self.goOnline()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { 
            self.requestRooms()
        }
    }
    
    func xmppStream(sender:XMPPStream, didNotAuthenticate error:DDXMLElement){
        let nudjError = NudjError.AuthenticationFailure 
        let wrappedError = NSError(domain: NudjError.domain, code: nudjError.rawValue, userInfo: [NSLocalizedDescriptionKey: nudjError.localizedDescription(),
            "Server response": error])
        delegate?.failedToConnect(wrappedError)
    }
    
    func xmppStream(sender: XMPPStream!, willSecureWithSettings settings: NSMutableDictionary!) {
        let api = API()
        let hostname = api.server.chatHostname
        let hostnameKey = kCFStreamSSLPeerName as String
        settings.setValue(hostname, forKey: hostnameKey)
    }
    
    func xmppStreamDidSecure(sender: XMPPStream!) {
        loggingPrint("Chat stream secured")
    }
    
    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError?) {
        loggingPrint("Chat stream disconnnected")
        if let error = error {
            delegate?.failedToConnect(error)
        }
    }
    
    func xmppStream(sender :XMPPStream, didReceiveMessage message:XMPPMessage) {
        let conferenceInvitation = message.elementForName("x", xmlns:"jabber:x:conference")
        
        if(conferenceInvitation != nil){
            let jidString = conferenceInvitation.attributesAsDictionary().valueForKey("jid") as! String
            let jid = XMPPJID.jidWithString(jidString)
            let chatroom = ChatRoomModel()
            let roomID = jid.user
            
            //Store new chat
            let defaults = NSUserDefaults.standardUserDefaults()
            let dict = ["isNew":true, "isRead":false]
            let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
            defaults.setObject(data, forKey:roomID)
            defaults.synchronize()
            
            //terminate room and reconnect
            chatroom.prepareChatModel(jidString, roomId: roomID, with:self.xmppStream!, delegate:self)
            self.listOfActiveChatRooms[roomID] = chatroom
        } else {
            // TODO: better error handling
            // loggingPrint("Received something from the messages delegate -> \(message.attributesAsDictionary())")
        }
    }
    
    func xmppStream(sender:XMPPStream, didReceiveIQ iq:XMPPIQ) -> Bool{

//        let roster = iq.elementForName("query", xmlns:"jabber:iq:roster")
//        let vCard = iq.elementForName("vCard", xmlns:"vcard-temp")
//        let conference = iq.elementForName("query", xmlns:"http://jabber.org/protocol/disco#items");
//        
//        // GET JABBER ROSTER item
//        if (roster != nil){
//            // let itemElements = roster.elementsForName("item") as NSArray;
//            //  loggingPrint("Recieved a roster for -> \(itemElements)");
//        }else if(vCard != nil){
//            //  let fullNameQuery = queryElement1.elementForName("from");
//            //  loggingPrint("Recieved a vcard for -> \(vCard)");
//        }else if(conference != nil){
//            // let itemElements = conference.elementsForName("item") as NSArray;
//            //  loggingPrint("Recieved conferences -> \(itemElements)");
//        }else{
//            // TODO: better error handling
//            //   loggingPrint("Recieved something i dont know -> \(iq)");
//        }
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
                delegate?.receivedMessage(jsqMessage, conference: sender.roomJID.bare())
            } else {
                // TODO: better error handling
                loggingPrint("Error getting sender of this message")
            }
        }
    }
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
//        loggingPrint("Chat room \(sender.roomJID) joined")
    }
    
    func xmppRoomDidCreate(sender: XMPPRoom!) {
//       loggingPrint("Chat room \(sender.roomJID) created")
    }
    
    func xmppRoomDidLeave(sender: XMPPRoom!) {
        loggingPrint("Chat room \(sender.roomJID) left")
        let roomID = sender.roomJID.user
        if let chatRoom = listOfActiveChatRooms[roomID] {
            chatRoom.teminateSession()
            listOfActiveChatRooms.removeValueForKey(roomID)
        }
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        loggingPrint("occupantDidJoinroom \(presence.type()) \(occupantJID)")
        let roomID = sender.roomJID.user
        if let chatRoom = listOfActiveChatRooms[roomID] {
            chatRoom.otherUserPresence = presence.type()
        }
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidUpdate occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        loggingPrint("occupantDidUpdateroom \(presence.type()) \(occupantJID)")
        let roomID = sender.roomJID.user
        if let chatRoom = listOfActiveChatRooms[roomID] {
            chatRoom.otherUserPresence = presence.type()
        }
    }
    
    func xmppRoom(sender: XMPPRoom!, occupantDidLeave occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
        loggingPrint("occupantDidLeaveroom \(presence.type()) \(occupantJID)")
        let roomID = sender.roomJID.user
        if let chatRoom = listOfActiveChatRooms[roomID] {
            chatRoom.otherUserPresence = presence.type()
        }
    }
    
    func xmppRoomDidDestroy(sender: XMPPRoom!) {
        loggingPrint("Chat room \(sender.roomJID) destroyed")
    }
    
    // MARK: Custom chat room methods
    
    func requestRooms(){
        let path = API.Endpoints.Chat.all()
        let params = API.Endpoints.Chat.paramsForLimit(100)
        let api = API.sharedInstance
        let conferenceDomain = api.server.charConferenceDomain
        api.request(.GET, path: path, params: params, closure:{
            (json: JSON) in
            if (json["status"].boolValue != true && json["data"] == nil) {
                // TODO: better error handling
                loggingPrint("ChatRoom Request Error -> \(json)")
            } else {
                self.listOfActiveChatRooms.removeAll(keepCapacity: false)
                for (_, obj) in json["data"]{
                    let data = obj["id"].string
                    let chatroom = ChatRoomModel()
                    chatroom.prepareChatModel("\(data!)@\(conferenceDomain)", roomId: data!, with:self.xmppStream!, delegate:self)
                    self.listOfActiveChatRooms[data!] = chatroom
                }
            }
            
            }, errorHandler: nil)
    }
    
    func getRoomIdFromJid(jid: XMPPJID) -> String {
        return jid.user
    }
    
    func getRoomIdFromJidString(jidString: String) -> String {
        let jid = XMPPJID.jidWithString(jidString)
        return getRoomIdFromJid(jid)
    }
}

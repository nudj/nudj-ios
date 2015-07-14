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
    func recievedMessage(content:JSQMessage)
    func recievedUser(content:NSDictionary)
}

class ChatModels: NSObject, XMPPRosterDelegate, XMPPRoomDelegate {
    var delegate : ChatModelsDelegate?
    var chatInformation = [NSManagedObject]();
    
    var jabberUsername:String?;
    var jabberPassword:String?;
    
    let chatServer = "chat.nudj.co";
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
    }
    
    
    func xmppStream(sender:XMPPStream, didNotAuthenticate error:DDXMLElement){
        
        println("Could not authenticate Error \(error)");
        
    }
    
    func xmppStream(sender :XMPPStream, didReceiveMessage message:XMPPMessage) {
        
        var conferenceInvitation = message.elementForName("x", xmlns:"jabber:x:conference")
        
        if(conferenceInvitation != nil){
            
            println("Received conference invite from ->  \(message.fromStr())")
            
            var jid = conferenceInvitation.attributesAsDictionary().valueForKey("jid") as! String
                
            println("conference id ->  \(jid)");
            
            self.acceptAndJoinChatRoom(jid);
            
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
        
        if message.body() != nil {
            
            println("from ->\(message.from().resource)")
            println("Message ->\(message.body())")
            
            var time : NSDate?
            
            if(message.elementsForName("delay").count > 0){
                
                let delay :DDXMLElement = message.elementForName("delay")
                var stringTimeStamp = delay.attributeStringValueForName("stamp")
                
                stringTimeStamp = stringTimeStamp.stringByReplacingOccurrencesOfString("T", withString: " ")
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSxxx";
                time = dateFormatter.dateFromString(stringTimeStamp)
                println("This is the delay timestamp value \(stringTimeStamp)")
                
                if(time == nil){
                time = NSDate()
                }
                
            }else{
                
                time = NSDate();
                
            }
            
            var jsqMessage = JSQMessage(senderId: message.from().resource, senderDisplayName: message.from().resource, date:time!, text: message.body())
            delegate?.recievedMessage(jsqMessage)
        }

    }
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        
        println("XMPPROOM JOINED")
        
    }
    
    func xmppRoomDidCreate(sender: XMPPRoom!) {
        
       println("XMPPROOM CREATED -> \(sender.roomJID)")

    }
    
    
    
    func getListOfActiveChatrooms(){
        
        //Auto rejoin
        
    }
    
    // MARK: Custom chat room methods
    
    func acceptAndJoinChatRoom(sender:String){
        
        var roomJID = XMPPJID.jidWithString(sender);
        xmppRoom = XMPPRoom(roomStorage: xmppRoomStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())

        
        var history:DDXMLElement = DDXMLElement(name:"history");
        history.addAttributeWithName("maxstanzas", stringValue:"100");
        
        xmppRoom!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        xmppRoom!.activate(xmppStream)
        
        xmppRoom!.joinRoomUsingNickname(jabberUsername, history: nil)

    }
    

    func getRoomObject(roomId:String, delegate: XMPPRoomDelegate) -> XMPPRoom {

        var roomJID = XMPPJID.jidWithString(roomId + "@conference.chat.nudj.co");

        var xmppRoom = XMPPRoom(roomStorage: xmppRoomStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())

        xmppRoom.addDelegate(delegate, delegateQueue: dispatch_get_main_queue())

        xmppRoom.activate(xmppStream)

        xmppRoom.joinRoomUsingNickname(jabberUsername, history: nil)

        xmppRoom.configureRoomUsingOptions(nil)

        return xmppRoom
    }


    func retrieveAllChatsList(){
     
        var serverJID = XMPPJID.jidWithString(chatServer)
        var iq = XMPPIQ.iqWithType("get", to: serverJID)
        iq.addAttributeWithName("from", stringValue: xmppStream!.myJID.full())
        
        var query = DDXMLElement.elementWithName("query") as! DDXMLElement
        query.addAttributeWithName("xmlns", stringValue: "http://jabber.org/protocol/disco#items")
        
        iq.addChild(query)
        xmppStream!.sendElement(iq);
    }
    
    
    func retrieveStoredChats (){
        
        
         //XMPPMessageArchiving_Message_CoreDataObject
        var moc = xmppMessageArchivingStorage!.mainThreadManagedObjectContext;
        var entityDescription = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: moc);
        var request = NSFetchRequest();
        request.entity = entityDescription;
        var error: NSError?;
        var messages :NSArray = moc.executeFetchRequest(request, error: &error)!;
        var message:XMPPMessageArchiving_Message_CoreDataObject?;
        
        // Retrieve all the messages for the current conversation
        for message in messages {
        var mm:Dictionary = [ message.bareJidStr:message.body()]
        println("All conversartion => \(mm)")
        }
        
    }
    
    
    
    //self.acceptAndJoinChatRoom("jnaurl@conference.chat.nudj.co")
   
    /*
    Recieved something i dont know -> <iq xmlns="jabber:client" from="3@chat.nudj.co/Antonios Macbook" to="6@chat.nudj.co/38442159071435158087723956" type="result" id="ADEC1B28-0C1A-4363-9B4B-01C5DE21A02F"><query xmlns="http://jabber.org/protocol/disco#info"><identity category="client" type="pc" name="imagent"></identity><feature var="http://jabber.org/protocol/xhtml-im"></feature><feature var="vcard-temp:x:update"></feature><feature var="http://jabber.org/protocol/disco#info"></feature><feature var="jabber:iq:version"></feature><feature var="http://jabber.org/protocol/si"></feature><feature var="http://jabber.org/protocol/sipub"></feature><feature var="http://jabber.org/protocol/bytestreams"></feature><feature var="apple:profile:efh-transfer"></feature><feature var="http://jabber.org/protocol/si/profile/file-transfer"></feature><feature var="apple:profile:transfer-extensions:rsrcfork"></feature><feature var="http://www.apple.com/xmpp/message-attachments"></feature></query></iq>
 
    Received something from the messages delegate -> jabber:client -> <message xmlns="jabber:client" from="jnaurl@conference.chat.nudj.co/3" to="6@chat.nudj.co/38442159071435158087723956" type="groupchat" id="iChat_16D5C663"><body>testing</body><html xmlns="http://jabber.org/protocol/xhtml-im"><body xmlns="http://www.w3.org/1999/xhtml"><span style="color: #000000;">testing</span></body></html></message> -> {
    from = "jnaurl@conference.chat.nudj.co/3";
    id = "iChat_16D5C663";
    to = "6@chat.nudj.co/38442159071435158087723956";
    type = groupchat;
    }
    */

    
    
    //    var presence = XMPPElement(name: "presence")
    //    presence.addAttributeWithName("from", stringValue: jabberUsername!)
    //    presence.addAttributeWithName("to", stringValue: "\(roomId)@conference.chat.nudj.co")
    //
    //    var history = XMPPElement(name: "history")
    //    history.addAttributeWithName("maxstanzas", stringValue: "100")
    //
    //    var x = XMPPElement(name: "x", xmlns: "http://jabber.org/protocol/muc")
    //
    //    x.addChild(history)
    //
    //    presence.addChild(x)
}
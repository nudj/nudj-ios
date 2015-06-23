//
//  ChatModels.swift
//  Nudge
//
//  Created by Antonio on 23/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import Foundation
import CoreData

protocol ChatModelsDelegate {
    func recievedMessage(content:NSDictionary)
    func recievedUser(content:NSDictionary)
}

class ChatModels: NSObject, XMPPRosterDelegate {
    var delegate : ChatModelsDelegate?
    var chatInformation = [NSManagedObject]();
    
    var jabberUsername:String?;
    var jabberPassword:String?;
    
    let chatServer = "chat.nudj.co";
    let appGlobalDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //XMPP ATTRIBUTES
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
    
    let  otherUsername = "5@chat.nudj.co";
    let  otherUserPassword = "SKozZ3AuQLUTcHm8FVxSFjxuC3wniMzczWN6g9n5LU6dnAarxXzlPOXIPwtT";
    
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
    
    // MARK: XMPP protocols and configs
    
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
        
        println("Has CONNECTED TO JABBER");
        
        
        /* var body = DDXMLElement.elementWithName("body") as! DDXMLElement;
        body.setStringValue("Testing message sending");
        
        var message = DDXMLElement.elementWithName("message") as! DDXMLElement;
        message.addAttributeWithName("type", stringValue:"chat");
        message.addAttributeWithName("to", stringValue:otherUsername);
        message.addChild(body);
        
        self.xmppStream?.sendElement(message);*/
        
    }
    
    
    func xmppStream(sender:XMPPStream, didNotAuthenticate error:DDXMLElement){
        
        println("Could not authenticate Error \(error)");
        
    }
    
    
    func xmppStream(sender :XMPPStream, didReceiveMessage message:XMPPMessage) {
        
        //var user :XMPPUserCoreDataStorageObject = xmppRosterStorage!.userForJID(message.from(), xmppStream:xmppStream!, managedObjectContext:self.managedObjectContext_roster());
        
        var msg = message.elementForName("body").stringValue()
        
        println("Receiving messages -> \(msg)");
        
        //NSNotificationCenter.defaultCenter().postNotificationName("updateContent", object:nil, userInfo:["message":msg]);
        
        delegate?.recievedMessage(["message":msg])
    }
    
    func xmppStream(sender:XMPPStream, didReceiveIQ iq:XMPPIQ) -> Bool{
        
        
        
        var queryElement = iq.elementForName("query", xmlns:"jabber:iq:roster")
        var queryElement1 = iq.elementForName("vCard", xmlns:"vcard-temp")
        
        // GET JABBER ROSTER item
        if (queryElement != nil){
            
            let itemElements = queryElement.elementsForName("item") as NSArray;
            println("Recieved a roster for -> \(itemElements)");
            
        }else if(queryElement1 != nil){
            
            //var fullNameQuery = queryElement1.elementForName("from");
            
            println("Recieved a vcard for -> \(iq)");
            
        }else{
            
            println("Recieved something i dont know -> \(iq)");
        }
        
        
        
        return true
        
    }

    
    
}
//
//  ChatViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: JSQMessagesViewController, ChatModelsDelegate {
    
    let avatarDiameter: UInt = 30
    
    var outgoingBubbleImageData :JSQMessagesBubbleImage?;
    var incomingBubbleImageData :JSQMessagesBubbleImage?;
    var templateImage :JSQMessagesAvatarImage?;
    var messages = NSMutableArray();
    
    var isLiked:Bool?
    var isArchived:Bool?
    
    var otherUserImage :JSQMessagesAvatarImage?
    var myImage :JSQMessagesAvatarImage?
    
    var otherUserBase64Image: String!
    var sendOnce:Bool = false;
    let appGlobalDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad();

        let id = appGlobalDelegate.user.id!
        // TODO: API strings
        self.senderId = String(id) + "@chat.nudj.co";
        
        self.senderDisplayName = appGlobalDelegate.user.name ?? ""

        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImageWithColor(appGlobalDelegate.appColor);
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor());

        self.showLoadEarlierMessagesHeader = false
        self.templateImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UserModel.getDefaultUserImage(), diameter: avatarDiameter)
        
        appGlobalDelegate.chatInst!.delegate = self
        
        self.userToken = appGlobalDelegate.user.token
        
        if let chatRoom = appGlobalDelegate.chatInst!.listOfActiveChatRooms[self.chatID] {
            self.messages = chatRoom.retrieveStoredChats()
            if chatRoom.xmppRoom != nil {
                // TODO: error handling
                loggingPrint("isChatRoomConnected:\(chatRoom.xmppRoom!.isJoined)");
            } else {
                self.dontUpdateButton = true
                self.inputToolbar?.contentView?.rightBarButtonItem?.enabled = false
            }
        } else {
            self.dontUpdateButton = true
            self.inputToolbar?.contentView?.rightBarButtonItem?.enabled = false
        }
        
        //Avatar Image
        self.myImage = self.setupAvatarImage(appGlobalDelegate.user.base64Image)
        self.otherUserImage = self.setupAvatarImage(self.otherUserBase64Image)
        
        self.favourite.selected = isLiked ?? false
        self.archive.selected = isArchived ?? false
    }

    //Get and convert base64 image
    func setupAvatarImage(base64Content:String?) -> JSQMessagesAvatarImage{
        if let base64Content = base64Content {
            if let decodedData = NSData(base64EncodedString: base64Content, options: [])
            {
                if let decodedimage :UIImage = UIImage(data: decodedData) {
                    return JSQMessagesAvatarImageFactory.avatarImageWithImage(decodedimage, diameter: avatarDiameter)
                }
            }
        }
        
        //Default
        return JSQMessagesAvatarImageFactory.avatarImageWithImage(UserModel.getDefaultUserImage(), diameter: avatarDiameter)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MixPanelHandler.sendData("ChatOpened")
        
        self.navigationController?.navigationBarHidden = true;
        self.tabBarController?.tabBar.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = false;
        appGlobalDelegate.chatInst!.delegate = appGlobalDelegate;

        self.filterOpened = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView?.collectionViewLayout.springinessEnabled = true
        self.finishReceivingMessageAnimated(true)
    }

    // JSQMessagesViewController method overrides
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if let chatRoom = appGlobalDelegate.chatInst!.listOfActiveChatRooms[self.chatID] {
            if chatRoom.xmppRoom != nil {
                if chatRoom.xmppRoom!.isJoined {
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    sendOnce = false
                    
                    appGlobalDelegate.registerForRemoteNotifications()
                    
                    chatRoom.xmppRoom!.sendMessageWithBody(text);
                    loggingPrint("Sent xmpp message");
                    self.finishSendingMessage()
                    
                    if let chatRoomPresence = chatRoom.otherUserPresence {
                        loggingPrint("this user is \(chatRoomPresence)")
                        if chatRoomPresence == "unavailable"{
                            self.sendOfflineMessage(text)
                        }
                    }else{
                        loggingPrint("this user is unavailable")
                        self.sendOfflineMessage(text)
                    }
                }
            }
        }
    }
    
    // JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let messages = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        return messages
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        if (message.senderId == self.senderId) {
            return self.outgoingBubbleImageData;
        }
        
        return self.incomingBubbleImageData;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        let img:JSQMessagesAvatarImage = (message.senderId == self.senderId) ? self.myImage! : self.otherUserImage!
        return img;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        /*if (indexPath.item % 3 == 0) {
        var message = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
        return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }*/
        
        let message = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages.objectAtIndex(indexPath.item) as! JSQMessage;
        
        //  iOS7-style sender name labels
        if (message.senderId == self.senderId) {
            return nil;
        }
        
        if (indexPath.item - 1 > 0) {
            let previousMessage = self.messages.objectAtIndex(indexPath.item - 1) as! JSQMessage
            if (previousMessage.senderId == message.senderId) {
                return nil;
            }
        }
        
        // Don't specify attributes to use the defaults.
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
       return nil
    }
    
    // UICollectionView DataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        /**
        *  Configure almost *anything* on the cell
        *
        *  Text colors, label text, label colors, etc.
        *
        *
        *  DO NOT set `cell.textView.font` !
        *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
        *
        *
        *  DO NOT manipulate cell layout information!
        *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
        */
        
        let msg = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        if let textView = cell.textView {
            let textColor = (msg.senderId == self.senderId) ? UIColor.whiteColor() : UIColor.blackColor()
            textView.textColor = textColor            
            let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:textColor, NSUnderlineStyleAttributeName: 1]
            textView.linkTextAttributes = attributes
        }
        
        return cell;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        // TODO: review
        /**
        *  iOS7-style sender name labels
        */
        
        /*var currentMessage = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
        if (currentMessage.senderId == self.senderId) {
        return 0.0
        }
        
        if (indexPath.item - 1 > 0) {
        var previousMessage = self.demoData.messages.objectAtIndex(indexPath.item - 1) as! JSQMessage
        if (previousMessage.senderId == currentMessage.senderId) {
        return 0.0
        }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;*/
        
        return 0.0
    }
    
    //pragma mark - Responding to collection view tap events
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        // TODO: why not implemented?
        loggingPrint("Load earlier messages")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        // TODO: why not implemented?
        loggingPrint("Tapped message bubble!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        // TODO: why not implemented?
        loggingPrint("Tapped cell at \(NSStringFromCGPoint(touchLocation))");
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        // TODO: why not implemented?
        loggingPrint("Tapped avatar!")
    }

    func recievedUser(content: NSDictionary) {
        // TODO: why not implemented?
    }
    
    func recievedMessage(content: JSQMessage, conference: String){
        let conferenceID = self.chatID + appGlobalDelegate.chatInst!.ConferenceUrl
        
        if(conferenceID == conference){
            self.scrollToBottomAnimated(true);
            self.messages.addObject(content)
            self.finishReceivingMessageAnimated(true)
        } else {
            let roomID = appGlobalDelegate.chatInst!.getRoomIdFromJidString(conference)
            
            //Store new chat
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
        }
    }
    
    override func labelsAction(sender: AnyObject!){
        //go to job details
        guard let jobID = Int(self.jobID) else {return} // TODO: self.jobID should be Int not String
        let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let jobDetailedView = storyboard.instantiateViewControllerWithIdentifier("JobDetailedView") as! JobDetailedViewController
        jobDetailedView.jobID = jobID
        
        self.navigationController?.pushViewController(jobDetailedView, animated:true);
    }
    
    override func dropDownAction(sender: AnyObject!) {
        func completeRequest(path: String, method: API.Method) {
            let api = API.sharedInstance
            api.request(method, path: path, errorHandler: { 
                error in
                loggingPrint("error for \(method) on \(path): \(error)")
            })
        }
        guard let jobID = Int(self.jobID) else {return} // TODO: self.jobID should be Int not String

        let selectedButton = sender as! UIButton
        // TODO: Ugh, get rid of switching on tag
        switch (selectedButton.tag) {
        case 1:
            //go to job details
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let jobDetailedView = storyboard.instantiateViewControllerWithIdentifier("JobDetailedView") as! JobDetailedViewController
            jobDetailedView.jobID = jobID
            
            self.navigationController?.pushViewController(jobDetailedView, animated:true);

        case 2:
            //go to profile
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let GenericProfileView = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController
            GenericProfileView.userId = Int(self.participantsID)!
            GenericProfileView.type = .Public
            GenericProfileView.preloadedName = self.participants
            
            self.navigationController?.pushViewController(GenericProfileView, animated:true);

        case 3:
            //Favourite Chat
            let endpoint = API.Endpoints.Jobs.likeByID(jobID) 
            if(selectedButton.selected){
                MixPanelHandler.sendData("Chat_UnfavouriteJob")
                completeRequest(endpoint, method: .DELETE)
            }else{
                MixPanelHandler.sendData("Chat_FavouriteJob")
                completeRequest(endpoint, method: .PUT)
            }
            selectedButton.selected = !selectedButton.selected
            
        case 4:
            // Block User
            guard let otherUserID = Int(participantsID) else {return} // TODO: self.participantsID should be Int not String
            let title = Localizations.Chat.Block.Title
            let message = Localizations.Chat.Block.Body.Format(participants)
            let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.preferredAction = cancelAction
            
            func addUserBlockingAction(title: String, endpointGenerator: (Int)->String, mixPanelTitle: String) -> Void {
                let action = UIAlertAction(title: title, style: .Destructive) {
                    _ in
                    let endpoint = endpointGenerator(otherUserID)
                    MixPanelHandler.sendData(mixPanelTitle)
                    let api = API.sharedInstance
                    api.request(.POST, path: endpoint, closure: {
                        json in
                        NSNotificationCenter.defaultCenter().postNotificationName(ChatListViewController.Notifications.Refetch.rawValue, object: nil, userInfo:nil)
                        // TODO: maybe filter out the offending user's chats locally while waiting for the server to respond
                    })
                    self.navigationController?.popViewControllerAnimated(true)
                }
                alert.addAction(action)
            }
            
            addUserBlockingAction(Localizations.Chat.Block.Button, endpointGenerator: API.Endpoints.Users.blockByID, mixPanelTitle: "Chat_BlockUserAction")
            addUserBlockingAction(Localizations.Chat.Report.Button, endpointGenerator: API.Endpoints.Users.reportByID, mixPanelTitle: "Chat_ReportUserAction")
            
            self.presentViewController(alert, animated: true, completion: nil)

        case 5:
            // Archive Conversation
            func dismissSelf(_: UIAlertAction) {
                self.navigationController?.popViewControllerAnimated(true)
            }
            guard let chatID = Int(self.chatID) else {return} // TODO: self.chatID should be Int not String
            let endpoint = API.Endpoints.Chat.archiveByID(chatID)
            if(selectedButton.selected){
                MixPanelHandler.sendData("Chat_RestoreFromArchive")
                completeRequest(endpoint, method: .DELETE)
                let alert = UIAlertController(title: Localizations.Chat.Restored.Title, message: nil, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Default, handler: dismissSelf)
                alert.addAction(defaultAction)
                alert.preferredAction = defaultAction
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                MixPanelHandler.sendData("Chat_Archive")
                completeRequest(endpoint, method: .PUT)
                let alert = UIAlertController(title: Localizations.Chat.Archived.Title, message: Localizations.Chat.Archived.Body, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Default, handler: dismissSelf)
                alert.addAction(defaultAction)
                alert.preferredAction = defaultAction
                self.presentViewController(alert, animated: true, completion: nil)
            }
            selectedButton.selected = !selectedButton.selected

        default:
            break;
        }
    }
    
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // TODO: review and dispose of commented-out code
        // Send The typing indicator
        /*if(!sendOnce){
            var conferenceID = self.chatID+""+appGlobalDelegate.chatInst!.ConferenceUrl
            
            var message = DDXMLElement.elementWithName("message") as! DDXMLElement
            message.addAttributeWithName("type",stringValue:"chat")
            message.addAttributeWithName("to", stringValue:conferenceID)
            
            var composing = DDXMLElement.elementWithName("composing") as! DDXMLElement
            composing.addAttributeWithName("xmlns", stringValue:"http://jabber.org/protocol/chatstates")
            message.addChild(composing)
            
            var mes = XMPPMessage(name:"composing", xmlns: "http://jabber.org/protocol/chatstates")
            
            appGlobalDelegate.chatInst!.listOfActiveChatRooms[self.chatID]!.xmppRoom!.sendMessage(mes)
            sendOnce = true;
            
            loggingPrint("Sent The typing indicator");
        }*/
        
        if let chatRoom = appGlobalDelegate.chatInst!.listOfActiveChatRooms[self.chatID] {
            if chatRoom.xmppRoom != nil {
                if !chatRoom.xmppRoom!.isJoined {
                    self.dontUpdateButton = true
                    self.inputToolbar?.contentView?.rightBarButtonItem?.enabled = false
                } else {
                    self.dontUpdateButton = false
                }
                
            } else {
                self.dontUpdateButton = true
                self.inputToolbar?.contentView?.rightBarButtonItem?.enabled = false
            }
        }
        
        return true
    }
    
    func isRecievingMessageIndication(user: String) {
        // TODO: do we need this?        
    }
    
    func sendOfflineMessage(message: String){
        guard let chatID = Int(self.chatID) else {return} // TODO: self.chatID should be Int not String
        guard let participantsID = Int(self.participantsID) else {return} // TODO: self.participantsID should be Int not String
        
        let path = API.Endpoints.Chat.notification()
        let params = API.Endpoints.Chat.paramsForMessage(chatID, userID: participantsID, message: message)
        API.sharedInstance.request(.PUT, path: path, params: params, closure: { 
            reponse in
            // TODO: error handling
            loggingPrint(reponse)
            }, errorHandler: {
                error in
                loggingPrint(error)
        })
    }
}

//
//  ChatViewController.swift
//  Nudge
//
//  Created by Antonio on 22/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: JSQMessagesViewController, ChatModelsDelegate{
    
    var outgoingBubbleImageData :JSQMessagesBubbleImage?;
    var incomingBubbleImageData :JSQMessagesBubbleImage?;
    var templateImage :JSQMessagesAvatarImage?;
    
    var messages = NSMutableArray();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        /*NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "updateContentFunction:",
            name: "updateContent",
            object: nil);*/
        
        self.title = "Conversation"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicatorImage(), style:UIBarButtonItemStyle.Plain, target:self, action:"performAction:");
        
        self.senderId = "antonio@chat.nudj.co";
        self.senderDisplayName = "Antonio";
        
        
        let bubbleFactory : JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory();
        
        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor());
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor());
        
        /**
        *  Load up our fake data for the demo
        */
        
        self.messages = [JSQMessage(senderId:self.senderId, senderDisplayName:self.senderDisplayName, date: NSDate.distantPast() as! NSDate, text: "Hi Robyn. \n\nMy friend Chris at Oracle is looking for a director of Business Development and i  thought i'd ask you. Are you interested?"),JSQMessage(senderId:"3@chat.nudge.co", senderDisplayName:"Robyn", date: NSDate(), text: "Hi Jeremy. all is well\nThis looks interesting. Thanks")];


        self.showLoadEarlierMessagesHeader = false
    
        self.templateImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "user_image_placeholder"), diameter: 30)
        
        var appGlobalDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appGlobalDelegate.chatInst!.delegate = self as ChatModelsDelegate
        
    }
    
    // ACTIONS
    func createDropDownView(){
        
        var dropDown = UIView(frame: CGRectMake(0, 0, 320, 50));
        dropDown.backgroundColor = UIColor.whiteColor();
        
        var jobDetailsIcon = UIImageView(image: UIImage(named: ""));
        var profileIcon = UIImageView(image: UIImage(named: ""));
        var favouriteIcon = UIImageView(image: UIImage(named: ""));
        var muteIcon = UIImageView(image: UIImage(named: ""));
        var archiveIcon = UIImageView(image: UIImage(named: ""));
        
    }
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    func performAction(sender: UIBarButtonItem){
        
        self.showTypingIndicator = !self.showTypingIndicator;
        
        
        /**
        *  Scroll to actually view the indicator
        */
        self.scrollToBottomAnimated(true);
        
        
        /**
        *  Allow typing indicator to show
        */
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            self.finishReceivingMessageAnimated(true);
            
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // JSQMessagesViewController method overrides
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        /**
        *  Sending a message. Your implementation of this method should do *at least* the following:
        *
        *  1. Play sound (optional)
        *  2. Add new id<JSQMessageData> object to your data source
        *  3. Call `finishSendingMessage`
        */
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        var message = JSQMessage (senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        self.messages.addObject(message)
        
        self.finishReceivingMessageAnimated(true)
        
    }
    
    
    // JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        var messages = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        return messages
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        var message = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        if (message.senderId == self.senderId) {
            return self.outgoingBubbleImageData;
        }
        
        return self.incomingBubbleImageData;
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        
        /**
        *  Return `nil` here if you do not want avatars.
        *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
        *
        *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        *
        *  It is possible to have only outgoing avatars or only incoming avatars, too.
        */
        
        /**
        *  Return your previously created avatar image data objects.
        *
        *  Note: these the avatars will be sized according to these values:
        *
        *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
        *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
        *
        *  Override the defaults in `viewDidLoad`
        
        */
        
        /*var message = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        if (message.senderId == self.senderId) {
        if (!NSUserDefaults.outgoingAvatarSetting()) {
        return nil;
        }
        }
        else {
        if (!NSUserDefaults.incomingAvatarSetting()) {
        return nil;
        }
        }*/
        
        //var dic = self.demoData.avatars as NSDictionary;
        
        return self.templateImage as! JSQMessageAvatarImageDataSource
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        /*if (indexPath.item % 3 == 0) {
        var message = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
        return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }*/
        
        return nil
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        var message = self.messages.objectAtIndex(indexPath.item) as! JSQMessage;
        
        /**
        *  iOS7-style sender name labels
        */
        if (message.senderId == self.senderId) {
            return nil;
        }
        
        if (indexPath.item - 1 > 0) {
            var previousMessage = self.messages.objectAtIndex(indexPath.item - 1) as! JSQMessage
            if (previousMessage.senderId == message.senderId) {
                return nil;
            }
        }
        
        /**
        *  Don't specify attributes to use the defaults.
        */
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        var message = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        
    }
    
    
    
    // UICollectionView DataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.messages.count
        
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        /**
        *  Override point for customizing cells
        */
        
        var cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
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
        
        var msg = self.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        
        if (msg.senderId == self.senderId) {
            cell.textView.textColor = UIColor.whiteColor()
        }else {
            cell.textView.textColor = UIColor.blackColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        
        return cell;
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
        
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        /*if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }*/
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
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
        
        println("Load earlier messages")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        println("Tapped message bubble!")
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        
        println("Tapped cell at \(NSStringFromCGPoint(touchLocation))");
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        
        println("Tapped avatar!")
    }
    
    
   // @objc func updateContentFunction(notification: NSNotification){
        
   //
    //}

    func recievedUser(content: NSDictionary) {
        
    }
    
    func recievedMessage(content:NSDictionary){
        //do stuff
        var msg = content["message"] as! String
    
        self.scrollToBottomAnimated(true);
    
        self.messages.addObject(JSQMessage(senderId:"3@chat.nudge.co", senderDisplayName:"", date:NSDate(), text:msg));
        self.finishReceivingMessageAnimated(true);
    }

}

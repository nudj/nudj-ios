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
    var selectedIndex: Int?
    let appGlobalDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad();

        let id = appGlobalDelegate.user!.id!
        self.senderId = String(id) + "@chat.nudj.co";
        self.senderDisplayName = appGlobalDelegate.user!.name!;

        let bubbleFactory : JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory();
        
        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor());
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor());

        self.showLoadEarlierMessagesHeader = false
    
        self.templateImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UserModel.getDefaultUserImage(), diameter: 30)
        
        appGlobalDelegate.chatInst!.delegate = self;
        self.messages = appGlobalDelegate.chatInst!.listOfActiveChatRooms[self.selectedIndex!].retrieveStoredChats()

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

    func performAction(sender: UIBarButtonItem){

        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        self.collectionView.collectionViewLayout.springinessEnabled = true

        self.finishReceivingMessageAnimated(true)
        
    }

    // JSQMessagesViewController method overrides
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {

        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        appGlobalDelegate.chatInst!.listOfActiveChatRooms[self.selectedIndex!].xmppRoom!.sendMessageWithBody(text);

        self.finishSendingMessage()
    
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

    func recievedUser(content: NSDictionary) {
        
    }
    
    func recievedMessage(content:JSQMessage, conference:String){
        
        println("Message via chat -> \(content.text) from:\(content.senderId) room:\(conference)")
        var conferenceID = self.chatID+""+appGlobalDelegate.chatInst!.ConferenceUrl
        
        if(conferenceID == conference){
        
        self.scrollToBottomAnimated(true);

        self.messages.addObject(content)
        
        self.finishReceivingMessageAnimated(true)
        
        }
    }
    
    override func dropDownAction(sender: AnyObject!) {
        
        let selectedButton = sender as! UIButton
        
        switch (selectedButton.tag) {
        case 1:
            
            //go to job details
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var jobDetailedView = storyboard.instantiateViewControllerWithIdentifier("JobDetailedView") as! JobDetailedViewController
            jobDetailedView.jobID = self.jobID
            
            self.navigationController?.pushViewController(jobDetailedView, animated:true);
            
        break;
        case 2:
            
            //go to profile
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var GenericProfileView = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController
            GenericProfileView.userId = self.participantsID.toInt()!
            GenericProfileView.type = .Public
            GenericProfileView.preloadedName = self.participants
            
            self.navigationController?.pushViewController(GenericProfileView, animated:true);

            
        break;
        case 3:
            //Favourite Chat
            if(selectedButton.selected){
                self.completeRequest("jobs/"+self.jobID+"/like", withType: "DELETE")
            }else{
                self.completeRequest("jobs/"+self.jobID+"/like", withType: "PUT")
            }
            selectedButton.selected = !selectedButton.selected
        
        break;
        case 4:
            // Mute Conversation
            //[self completeRequest:[NSString stringWithFormat:@"contacts/%@/mute",_chatID] withType:@"PUT"];
            
            selectedButton.selected = !selectedButton.selected
        
        break;
        case 5:
            // Archive Conversation
            selectedButton.selected = !selectedButton.selected
            self.completeRequest("chat/"+self.chatID+"/archive", withType: "PUT")
        
        break;
        default:
        break;
        
        }
        
        
    }
    

}

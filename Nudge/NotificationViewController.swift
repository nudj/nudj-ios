//
//  NotificationViewController.swift
//  Nudge
//
//  Created by Antonio on 03/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON
import MessageUI

class NotificationViewController: UITableViewController, NotificationCellDelegate, MFMessageComposeViewControllerDelegate {

    var data = [Notification]()
    
    let cellIdentifier = "NotificationCell"
    var nextLink:String? = nil
    var noContentImage = NoContentPlaceHolder()
    var selectedContent: Notification?
    
    override func viewWillAppear(animated: Bool) {
        
        MixPanelHandler.sendData("NotificationsTabOpened")
        
        self.tabBarController?.tabBar.hidden = false
        loadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableView.tableFooterView = UIView(frame: CGRectZero);

        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(self.noContentImage.createNoContentPlaceHolder(self.view, imageTitle: "no_notifications"))
        
        //set badge counter to 0
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        //mark notifications as read
        
        //Reupdate frame
        self.noContentImage.frame = CGRectMake((self.view.frame.size.width/2) - 200/2 , ((view.frame.size.height/2) - 149/2) - 64, 200,149)

    }
    

    func refresh() {
        loadData(false, url: nil)
    }

    func loadData(append:Bool = true, url:String? = nil) {

        var defaulUrl = "notifications?params=chat.id,sender.name,sender.image&limit=100"

        API.sharedInstance.get(url == nil ? defaulUrl : url!, closure: {data in

            //if !append {
                self.data.removeAll(keepCapacity: false)
            //}

            self.nextLink = data["pagination"]["next"].string
            self.populate(data)

        }, errorHandler: {error in
            self.refreshControl?.endRefreshing()
        })
    }
    
    //, referred by who
    
    func loadNext() {
        if (nextLink == nil) {
            return
        }

        loadData(true, url: self.nextLink)
    }

    func populate(data:JSON) {

        print("Notifications url request response ->\(data)");

        for (id, obj) in data["data"] {
            
            if let val = Notification.createFromJSON(obj){
                self.data.append(val)
            }
            
        }
        
        self.navigationController?.tabBarItem.badgeValue = nil
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        
        if(self.data.count == 0){
            
            self.noContentImage.showPlaceholder()
            
        }else{
            
            self.noContentImage.hidePlaceholder()
        }
    }
    
    // MARK: -- UITableViewDataSource --
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.data.count
        
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 120
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! NotificationCell
        
        cell.delegate = self
        cell.setup(self.data[indexPath.row])
        
        
        return cell
    }
    
    // MARK: -- UITableViewDelegate --
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

       //Mark as read
        
    }

    func didTapUserImage(cell: NotificationCell) {
        
        
        print("Tapped user image")
        
        //go to profile
        let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var GenericProfileView = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController
        GenericProfileView.userId = Int(cell.notificationData!.senderId!)!
        GenericProfileView.type = .Public
        GenericProfileView.preloadedName = cell.notificationData?.senderName
        
        self.navigationController?.pushViewController(GenericProfileView, animated:true);
    }
    
    func didPressRightButton(cell:NotificationCell){
        
        if(cell.type == nil){
            
            return;
        }
        
        if cell.isRead == false {
            
            cell.readStatus(true)
            cell.markAsRead()
        }
        
        self.selectedContent = cell.notificationData
        
        switch cell.type! {
        case .AskToRefer:
            print("Details")
            MixPanelHandler.sendData("Notification_DetailButtonClicked")
            self.goToView("JobDetailedView", contentId: cell.notificationData!.jobID)
            break;
        case .AppApplication:
            print("go to chat")
            MixPanelHandler.sendData("Notification_MessageButtonClicked")
            self.gotTochat(cell)
            break;
        case .WebApplication:
            print("sms")
            MixPanelHandler.sendData("Notification_SmsButtonClicked")
            self.createSms(cell.notificationData!.senderPhoneNumber)
            break;
        case .MatchingContact:
            print("nudge")
            MixPanelHandler.sendData("Notification_ReferButtonClicked")
            self.nudge(cell.notificationData!.jobID)
            break;
        case .AppApplicationWithNoReferral:
            print("go to chat")
            MixPanelHandler.sendData("Notification_MessageButtonClicked")
            self.gotTochat(cell)
            break;
        case .WebApplicationWithNoReferral:
            print("sms")
            MixPanelHandler.sendData("Notification_SmsButtonClicked")
             self.createSms(cell.notificationData!.senderPhoneNumber)
            break;
        default:
            break;
        }
        
        
    }
    
    func didPressCallButton(cell: NotificationCell) {
        MixPanelHandler.sendData("Notification_CallButtonClicked")
        
        if let phonenumber = cell.notificationData?.senderPhoneNumber{
            
            var phoneNo = "tel://"+phonenumber
            
            if let phoneUrl = NSURL(string: phoneNo){
                
                if(UIApplication.sharedApplication().canOpenURL(phoneUrl)){
                   
                    UIApplication.sharedApplication().openURL(phoneUrl)
                    
                }else{
                    
                    var alert = UIAlertView(title: "Cannot initiate a Phone call", message: "Nudj is unable to initiate a phone call right now, please try again later", delegate: nil, cancelButtonTitle: "OK");
                    alert.show()
                    
                }
                
            }
        }else{
            
            print("no phonumber")
        }
    }
    
    func createSms(receiver:String?){
        
        if let reciverNumber = receiver {
            if(MFMessageComposeViewController.canSendText()){
            
                var messageComposer = MFMessageComposeViewController()
                messageComposer.messageComposeDelegate = self
                messageComposer.body = ""
                messageComposer.recipients = [reciverNumber]
                self.presentViewController(messageComposer, animated: true, completion: nil)
                
            }else{
                
                var alert = UIAlertView(title: "Text message services unavailabe", message: "Creating text messages is unavailabe for this device", delegate: nil, cancelButtonTitle: "OK");
                alert.show()
                
            }
        }else{
            
            print("no phonumber")
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
  
        if result == MessageComposeResultFailed {
            
                var alert = UIAlertView(title: "Text message failed", message: "There was an error in sending you message. Please try again", delegate: nil, cancelButtonTitle: "OK");
                alert.show()
        
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }

    func nudge(jobID:String?){
        
        self.goToView("AskReferralView", contentId:jobID)
        
    }
    
    func goToView(viewId: String, contentId:String?){
        
        let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if(viewId == "AskReferralView"){
            
            if let job  = contentId?.toInt() {
                var askView = storyboard.instantiateViewControllerWithIdentifier(viewId) as! AskReferralViewController
                askView.jobId = job
                askView.isNudjRequest = true
                askView.isSlideTransition = true
                self.navigationController?.pushViewController(askView, animated: true);
            }
            
        }else{
            
            if let job  = contentId?.toInt() {
                var detailsView = storyboard.instantiateViewControllerWithIdentifier(viewId) as! JobDetailedViewController
                detailsView.jobID = contentId
                self.navigationController?.pushViewController(detailsView, animated: true);
            }
            
        }

    }
    
    func gotTochat(cell:NotificationCell){
        
        let chatData = cell.notificationData!
        cell.userInteractionEnabled = false
        
        if chatData.chatId != nil && !chatData.chatId!.isEmpty{
            
            self.gotTochatAction(cell)
            
        }else{
            
            performSegueWithIdentifier("goToChat", sender: self)
            cell.userInteractionEnabled = true
        }
     
    }
    
    func gotTochatAction(cell:NotificationCell){
        
        let chatData = cell.notificationData!
        
        var chatView:ChatViewController = ChatViewController()
        
        chatView.chatID = chatData.chatId;
        chatView.participants =  chatData.senderName
        chatView.participantsID = chatData.senderId
        chatView.chatTitle = chatData.jobTitle
        chatView.jobID = chatData.jobID
        
        var imageData = UIImagePNGRepresentation(cell.profileImage.image)
        let base64String = imageData.base64EncodedStringWithOptions(.allZeros)
        chatView.otherUserBase64Image = base64String
        
        cell.userInteractionEnabled = true
        self.navigationController?.pushViewController(chatView, animated: true)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationNavigationController = segue.destinationViewController as? UINavigationController {
            let chatView = destinationNavigationController.topViewController as! InitiateChatViewController
            
            chatView.jobid = selectedContent!.jobID
            chatView.userid = selectedContent!.senderId
            chatView.username = selectedContent!.senderName
            chatView.notificationid = selectedContent!.notificationId
        
        }
        
    }
    
}

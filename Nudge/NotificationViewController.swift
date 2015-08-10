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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableView.tableFooterView = UIView(frame: CGRectZero);

        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)

        loadData()
    }
    

    func refresh() {
        loadData(append: false, url: nil)
    }

    func loadData(append:Bool = true, url:String? = nil) {

        var defaulUrl = "notifications?params=chat.id,sender.name,sender.image&limit=10"

        API.sharedInstance.get(url == nil ? defaulUrl : url!, closure: {data in

            if !append {
                self.data.removeAll(keepCapacity: false)
            }

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

        loadData(append: true, url: self.nextLink)
    }

    func populate(data:JSON) {

        println("Notifications url request response ->\(data)");

        for (id, obj) in data["data"] {
            
            if let val = Notification.createFromJSON(obj){
                self.data.append(val)
            }
            
        }
        
        self.navigationController?.tabBarItem.badgeValue = nil
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
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

    func didPressRightButton(cell:NotificationCell){
        
        if(cell.type == nil){
            
            return;
        }
        
        if cell.isRead == false {
            
            cell.readStatus(true)
            cell.markAsRead()
        }
        
        switch cell.type! {
        case .AskToRefer:
            println("Details")
            self.goToView("JobDetailedView", contentId: cell.notificationData!.jobID)
            break;
        case .AppApplication:
            println("go to chat")
            self.gotTochat(cell.notificationData!)
            break;
        case .WebApplication:
            println("sms")
            self.createSms(cell.notificationData!.senderPhoneNumber)
            break;
        case .MatchingContact:
            println("nudge")
            self.nudge(cell.notificationData!.jobID)
            break;
        case .AppApplicationWithNoReferral:
            println("go to chat")
            self.gotTochat(cell.notificationData!)
            break;
        case .WebApplicationWithNoReferral:
            println("sms")
             self.createSms(cell.notificationData!.senderPhoneNumber)
            break;
        default:
            break;
        }
        
        
    }
    
    func didPressCallButton(cell: NotificationCell) {
        
        if let phonenumber = cell.notificationData?.senderPhoneNumber{
            
            if let phoneUrl = NSURL(string: phonenumber){
                
                if(UIApplication.sharedApplication().canOpenURL(phoneUrl)){
                   
                    UIApplication.sharedApplication().openURL(phoneUrl)
                    
                }else{
                    
                    var alert = UIAlertView(title: "Cannot initiate a Phone call", message: "Nudj is unable to initiate a phone call right now, please try again later", delegate: nil, cancelButtonTitle: "OK");
                    alert.show()
                    
                }
                
            }
        }else{
            
            println("no phonumber")
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
            
            println("no phonumber")
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
  
        if result.value == MessageComposeResultFailed.value {
            
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
    
    func gotTochat(chatData:Notification){
        
        if chatData.chatId != nil && !chatData.chatId!.isEmpty{
            
            //if chat id is in list of active chats go to that message
            //else generate
            
            /*if(){
                
            }else{
                
            }*/
            var chatView:ChatViewController = ChatViewController()
    
            chatView.chatID = chatData.chatId;
            chatView.participants =  chatData.senderName
            chatView.participantsID = chatData.senderId
            chatView.chatTitle = chatData.jobTitle
            chatView.jobID = chatData.jobID
            chatView.otherUserImageUrl = chatData.senderImage
            
            self.navigationController?.pushViewController(chatView, animated: true)
            
        }else{
            
            var alert = UIAlertView(title: "Coming soon", message: "This feature is currently in development, it will be available in the next update", delegate: nil, cancelButtonTitle: "OK");
            alert.show()
            
            /*var params = ["job_id":chatData.jobID!,"user_id":chatData.senderId!,"message":"testing endpoint"]
            API.sharedInstance.put("nudge/chat", params:params, closure: { json in
                println("success \(json)")
            }, errorHandler: { error in
                println("error \(error)")
            })*/
            
        }
     
    }
    
    
}

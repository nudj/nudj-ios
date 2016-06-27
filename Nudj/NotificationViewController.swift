//
//  NotificationViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON
import MessageUI

class NotificationViewController: UITableViewController, SegueHandlerType, NotificationCellDelegate, MFMessageComposeViewControllerDelegate {
    
    enum SegueIdentifier: String {
        case GoToChat = "goToChat"
    }

    var data = [Notification]()
    
    let cellIdentifier = "NotificationCell"
    var nextLink: String? = nil
    var noContentImage = NoContentPlaceHolder()
    var selectedContent: Notification?
    
    override func viewWillAppear(animated: Bool) {
        MixPanelHandler.sendData("NotificationsTabOpened")
        
        self.tabBarController?.tabBar.hidden = false
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableView.tableFooterView = UIView(frame: CGRectZero);

        self.refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(self.noContentImage.alignInSuperView(self.view, imageTitle: "no_notifications"))
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        //mark notifications as read
        
        // Reupdate frame
        // TODO: magic numbers
        self.noContentImage.frame = CGRectMake((self.view.frame.size.width/2) - 200/2 , ((view.frame.size.height/2) - 149/2) - 64, 200,149)
    }

    func refresh() {
        loadData(false)
    }

    private func loadData(append: Bool = true, path: String? = nil) {
        let path = path ?? API.Endpoints.Notifications.base
        let params = API.Endpoints.Notifications.paramsForList(100)

        API.sharedInstance.request(.GET, path: path, params: params, closure: {data in
            // TODO: review the following
            //if !append {
                self.data.removeAll(keepCapacity: false)
            //}

            self.nextLink = data["pagination"]["next"].string
            self.populate(data)

        }, errorHandler: {error in
            self.refreshControl?.endRefreshing()
        })
    }
    
    private func loadNext() {
        if (nextLink == nil) {
            return
        }

        loadData(true, path: self.nextLink)
    }

    func populate(data:JSON) {
        for (_, obj) in data["data"] {
            if let val = Notification(json: obj){
                self.data.append(val)
            }
        }
        
        self.navigationController?.tabBarItem.badgeValue = nil
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        
        if(self.data.count == 0){
            self.noContentImage.hidden = false
        } else {
            self.noContentImage.hidden = true
        }
    }
    
    // MARK: -- UITableViewDataSource --
    // TODO: refactor out the data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: magic number
        return 120
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! NotificationCell
        cell.delegate = self
        cell.setup(self.data[indexPath.row])
        return cell
    }
    
    // MARK: -- UITableViewDelegate --
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       // TODO: Mark as read
    }

    func didTapUserImage(cell: NotificationCell) {
        //go to profile
        let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let GenericProfileView = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController
        GenericProfileView.userId = Int(cell.notificationData!.senderId!)!
        GenericProfileView.type = .Public
        GenericProfileView.preloadedName = cell.notificationData?.senderName
        
        self.navigationController?.pushViewController(GenericProfileView, animated:true);
    }
    
    func didPressRightButton(cell: NotificationCell){
        
        guard let cellType = cell.type else {
            return
        }
        
        if cell.isRead == false {
            cell.readStatus(true)
            cell.markAsRead()
        }
        
        self.selectedContent = cell.notificationData
        
        switch cellType {
        case .AskToRefer:
            MixPanelHandler.sendData("Notification_DetailButtonClicked")
            self.goToView("JobDetailedView", contentId: cell.notificationData!.jobID, jobTitle: cell.notificationData!.jobTitle)
            break
        case .AppApplication:
            MixPanelHandler.sendData("Notification_MessageButtonClicked")
            self.gotTochat(cell)
            break
        case .WebApplication:
            MixPanelHandler.sendData("Notification_SmsButtonClicked")
            self.createSms(cell.notificationData!.senderPhoneNumber)
            break
        case .MatchingContact:
            MixPanelHandler.sendData("Notification_ReferButtonClicked")
            self.nudge(cell.notificationData!.jobID, jobTitle: cell.notificationData!.jobTitle)
            break
        case .AppApplicationWithNoReferral:
            MixPanelHandler.sendData("Notification_MessageButtonClicked")
            self.gotTochat(cell)
            break
        case .WebApplicationWithNoReferral:
            MixPanelHandler.sendData("Notification_SmsButtonClicked")
             self.createSms(cell.notificationData!.senderPhoneNumber)
            break
        }
    }
    
    func didPressCallButton(cell: NotificationCell) {
        MixPanelHandler.sendData("Notification_CallButtonClicked")
        
        // TODO: instead of failing and showing an alert, do not enable the call button if it is not available
        if let phonenumber = cell.notificationData?.senderPhoneNumber {
            let phoneNo = "tel://" + phonenumber
            if let phoneUrl = NSURL(string: phoneNo){
                if(UIApplication.sharedApplication().canOpenURL(phoneUrl)){
                    UIApplication.sharedApplication().openURL(phoneUrl)
                } else {
                    let alert = UIAlertController(title: Localizations.Phone.Unavailable.Title, message: Localizations.Phone.Unavailable.Body, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    alert.preferredAction = defaultAction
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        } else {
            // TODO: improve error handling
            loggingPrint("no phone number")
        }
    }
    
    func createSms(receiver:String?){
        if let reciverNumber = receiver {
            // TODO: instead of failing and showing an alert, do not enable the SMS feature if it is not available
            if(MFMessageComposeViewController.canSendText()){
                let messageComposer = MFMessageComposeViewController()
                messageComposer.messageComposeDelegate = self
                messageComposer.body = ""
                messageComposer.recipients = [reciverNumber]
                self.presentViewController(messageComposer, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: Localizations.Sms.Unavailable.Title, message: Localizations.Sms.Unavailable.Body, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Default, handler: nil)
                alert.addAction(defaultAction)
                alert.preferredAction = defaultAction
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            // TODO: better error handling
            loggingPrint("no phone number")
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        if result == MessageComposeResultFailed {
            let alert = UIAlertController(title: Localizations.Sms.Failed.Title, message: Localizations.Sms.Failed.Body, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Default, handler: nil)
            alert.addAction(defaultAction)
            alert.preferredAction = defaultAction
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func nudge(jobID:String?, jobTitle: String?){
        self.goToView("AskReferralView", contentId:jobID, jobTitle: jobTitle)
    }
    
    func goToView(viewId: String, contentId: String?, jobTitle: String?) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let job = Int(contentId ?? "") else {
            return
        }
        
        if(viewId == "AskReferralView"){
            let askView = storyboard.instantiateViewControllerWithIdentifier(viewId) as! AskReferralViewController
            askView.jobId = job
            askView.jobTitle = jobTitle
            askView.isNudjRequest = true
            self.navigationController?.pushViewController(askView, animated: true);
        } else {
            let detailsView = storyboard.instantiateViewControllerWithIdentifier(viewId) as! JobDetailedViewController
            detailsView.jobID = job
            detailsView.currentUser = UserModel.getLocal()
            self.navigationController?.pushViewController(detailsView, animated: true)
        }
    }
    
    func gotTochat(cell:NotificationCell) {
        let chatData = cell.notificationData!
        cell.userInteractionEnabled = false
        
        if chatData.chatId != nil && !chatData.chatId!.isEmpty{
            self.gotTochatAction(cell)
        } else {
            performSegueWithIdentifier(.GoToChat, sender: self)
            cell.userInteractionEnabled = true
        }
    }
    
    func gotTochatAction(cell:NotificationCell){
        let chatData = cell.notificationData!
        
        let chatView:ChatViewController = ChatViewController()
        chatView.chatID = chatData.chatId;
        chatView.participants =  chatData.senderName
        chatView.participantsID = chatData.senderId
        chatView.chatTitle = chatData.jobTitle
        chatView.jobID = chatData.jobID
        
        if let image = cell.profileImage.image {
            let imageData = UIImagePNGRepresentation(image)
            let base64String = imageData?.base64EncodedStringWithOptions([])
            chatView.otherUserBase64Image = base64String
        }
        
        cell.userInteractionEnabled = true
        self.navigationController?.pushViewController(chatView, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .GoToChat:
            let chatView = segue.destinationViewController as! InitiateChatViewController
            chatView.jobid = Int(selectedContent!.jobID!) ?? 0 // TODO: straighten these optional types out
            chatView.userid = Int(selectedContent!.senderId!) ?? 0
            chatView.username = selectedContent!.senderName!
            chatView.notificationid = selectedContent!.notificationId!
        }
    }
}

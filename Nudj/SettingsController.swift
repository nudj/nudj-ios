//
//  SettingsTableViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingsController: UIViewController, UITableViewDataSource, UITableViewDelegate, SocialStatusDelegate, UIAlertViewDelegate {

    var statusButton = StatusButton()
    var socialStatuses = [String:Bool]()
    
    let cellIdentifier = "SettingsCell";
    var jobsSelected:String?;
    var isPolicy = false;

    var socialhander :SocialHandlerModel?
    var statusParent :SocialStatus?
    let structure: [[SettingsItem]] = [
        [
            SettingsItem(name: Localizations.Settings.Title.Profile, action: "showYourProfile"),
            SettingsItem(name: Localizations.Settings.Title.Status, action: "showStatusPicker"),
            SettingsItem(name: Localizations.Settings.Title.SavedJobs, action: "goToSavedJobs"),
            SettingsItem(name: Localizations.Settings.Title.PostedJobs, action: "goToPostedJobs"),
            SettingsItem(name: Localizations.Settings.Title.Chats, action: "goToChats")
        ],
        [
            //SettingsItem(name: "LinkedIn", action: "linkedin"),
            SettingsItem(name: Localizations.Settings.Title.Facebook, action: "facebook")
        ],
        [
            //SettingsItem(name: "Invite Friends", action: ""),
            SettingsItem(name: Localizations.Settings.Title.Terms, action: "goToTerms"),
            SettingsItem(name: Localizations.Settings.Title.Privacy, action: "goToTerms"), // TODO: check this
            SettingsItem(name: Localizations.Settings.Title.Feedback, action: "goToFeedBack")
        ],
        [
            //SettingsItem(name: "Log Out", action: "goToLogin"),
            SettingsItem(name: Localizations.Settings.Title.DeleteAccount, action: "goToLogin") // TODO: check this
        ]
    ];

    @IBOutlet weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        table.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.socialhander = SocialHandlerModel(viewController: self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MixPanelHandler.sendData("SettingsTabOpened")
        
        self.tabBarController?.tabBar.hidden = false

        // TODO: Ugh fix this singleton mess
        // TODO: API strings
        BaseController().apiRequest(API.Method.GET, path: "users/me?params=user.status,user.facebook,user.linkedin", closure: { json in
            loggingPrint(json)
            if (json["data"]["status"] != nil && json["data"]["status"].stringValue != "") {
                self.statusButton.setTitleByIndex(json["data"]["status"].intValue)
            }
            self.socialStatuses = ["facebook": json["data"]["facebook"].boolValue ,"linkedin":json["data"]["linkedin"].boolValue]
            self.table.reloadData()
        })
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return structure.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure[section].count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SettingsCell
        let data = structure[indexPath.section][indexPath.row]

        cell.setTitle(data.name);

        if (indexPath.section == 3) {
            cell.alignCenter()
            cell.textLabel?.textColor = UIColor.redColor()
        } else {
            cell.alignLeft()
        }

        if (data.action == "showStatusPicker") {
            cell.accessoryView = self.statusButton
            cell.accessoryView?.userInteractionEnabled = false
        } else if(data.action == "linkedin"){
            cell.imageView!.image = UIImage(named: "linkdin")
            if(self.socialStatuses.count > 0){
                let social = SocialStatus(status: self.socialStatuses["linkedin"]!, and: data.action)
                social.delegate = self
                cell.accessoryView = social
            }else{
                cell.accessoryView = nil;
            }
            
        } else if(data.action == "facebook"){
            cell.imageView!.image = UIImage(named: "facebook_icon")
            if(self.socialStatuses.count > 0){
                let social = SocialStatus(status: self.socialStatuses["facebook"]!, and: data.action)
                social.delegate = self
                cell.accessoryView = social;
            }else{
                cell.accessoryView = nil;
            }
        }else if(data.action == "goToLogin"){
            cell.accessoryView = nil
            cell.accessoryType = UITableViewCellAccessoryType.None
        }else{
            cell.accessoryView = nil
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }

        return cell
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // TODO: magic numbers
        return section == structure.count - 1 ? 0.01: 0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // TODO: magic numbers
        return section == 0 ? 0.01: 0
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: magic numbers        
        if (indexPath.section == 3) {
            return 88;
        }else{
            return 44;
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let action = structure[indexPath.section][indexPath.row].action
        let name = structure[indexPath.section][indexPath.row].name
        if (action.isEmpty) {
            return
        }
        
        // TODO: this is too fragile use a flag property
        isPolicy = (name == Localizations.Settings.Title.Privacy)

        if(action == "linkedin"){
            // nothing
        }else if(action == "facebook"){
            // nothing
        }else if(action == "goToLogin"){
            // TODO: move to UIAlertController
            let alertview = UIAlertView(title: Localizations.Settings.Delete.Title,
                message: Localizations.Settings.Delete.Body,
                delegate:self,
                cancelButtonTitle: Localizations.General.Button.Cancel,
                otherButtonTitles: Localizations.Settings.Delete.Button)
            // TODO: why 3?
            alertview.tag = 3
            alertview.show();
        }else{
            self.jobsSelected = action
            performSegueWithIdentifier(action, sender: self)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // goToLogin
        if (segue.destinationViewController.isKindOfClass(LoginController)) {
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.deleteAccount()
        }

        // showYourProfile
        if (segue.destinationViewController.isKindOfClass(GenericProfileViewController)) {
            if let controller = (segue.destinationViewController as? GenericProfileViewController) {
                controller.type = .Own
            }
        }

        // saved jobs or posted jobs
        if (segue.destinationViewController.isKindOfClass(SavedPostedJobs)) {
            if let controller = (segue.destinationViewController as? SavedPostedJobs) {
                if(self.jobsSelected == "goToPostedJobs"){
                    controller.title = Localizations.Settings.Title.PostedJobs
                    controller.requestParams = "mine"
                }
                
                if(self.jobsSelected == "goToSavedJobs"){
                    controller.title = Localizations.Settings.Title.SavedJobs
                    controller.requestParams = "liked"
                }
            }
        }
        
        if(segue.destinationViewController.isKindOfClass(TermsViewController)){
            if let controller = (segue.destinationViewController as? TermsViewController) {
                if(isPolicy == true){
                    controller.isPrivacy = true
                }
            }
        }
        
        if(segue.destinationViewController.isKindOfClass(ChatListViewController)){
            if let controller = (segue.destinationViewController as? ChatListViewController) {
                 controller.isArchive = true
            }
        }
    }

    func didTap(statusIdentifier: String, parent:SocialStatus) {
        self.statusParent = parent;
        if(parent.currentStatus!){
            // TODO: move to UIAlertController
            let title = Localizations.Settings.Disconnect.Title.Format(statusIdentifier)
            let message = Localizations.Settings.Disconnect.Title.Body(statusIdentifier)
            let alertview = UIAlertView(title: title, message:message, delegate:self, cancelButtonTitle: Localizations.General.Button.Cancel, otherButtonTitles: Localizations.Settings.Disconnect.Button)
            alertview.tag = statusIdentifier == "facebook" ? 0 : 1
            alertview.show();
        }else{
            self.handleSocialAction(statusIdentifier)
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        // TODO: these magic tags should be an enum
        if alertView.tag == 3 {
            if(buttonIndex == 1){
                MixPanelHandler.sendData("DeleteAcountAction")
                self.jobsSelected = "goToLogin"
                performSegueWithIdentifier("goToLogin", sender: self)
            }
        }else{
            if(buttonIndex == 1){
                self.handleSocialAction(alertView.tag ==  0 ? "facebook" : "linkedin")
            }
        }
    }
    
    func handleSocialAction(statusIdentifier:String){
        // TODO: refactor and move to UIAlertController
        let alert = UIAlertView(title: "", message: "", delegate: nil, cancelButtonTitle: Localizations.General.Button.Ok)
        
        if(statusIdentifier == "facebook"){
            self.socialhander!.configureFacebook(self.statusParent!.currentStatus!, completionHandler: { success in
                
                if(success){
                    self.statusParent!.updateStatus()
                    self.socialStatuses["facebook"] = self.statusParent!.currentStatus!
                    if(self.statusParent!.currentStatus!){
                        alert.title = Localizations.Settings.Facebook.Connected.Title
                        alert.message = Localizations.Settings.Facebook.Connected.Body
                    }else{
                        alert.title = Localizations.Settings.Facebook.Disconnected.Title
                        alert.message = Localizations.Settings.Facebook.Disconnected.Body
                    }
                    alert.show()
                }
            })
        }
        
        if(statusIdentifier == "linkedin"){
            self.socialhander!.configureLinkedin(self.statusParent!.currentStatus!, completionHandler: { success in
                if(success){
                    self.statusParent!.updateStatus()
                    self.socialStatuses["linkedin"] = self.statusParent!.currentStatus!
                    if(self.statusParent!.currentStatus!){
                        alert.title = Localizations.Settings.Linkedin.Connected.Title
                        alert.message = Localizations.Settings.Linkedin.Connected.Body
                    }else{
                        alert.title = Localizations.Settings.Linkedin.Disconnected.Title
                        alert.message = Localizations.Settings.Linkedin.Disconnected.Body
                    }
                    alert.show()
                    self.table.reloadData();
                }
            })
        }
    }
}

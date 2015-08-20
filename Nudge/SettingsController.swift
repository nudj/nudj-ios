//
//  SettingsTableViewController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 2.04.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import Alamofire
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
            SettingsItem(name: "My Profile", action: "showYourProfile"),
            SettingsItem(name: "My Status", action: "showStatusPicker"),
            //SettingsItem(name: "Notifications", action: ""),
            SettingsItem(name: "Saved Jobs", action: "goToSavedJobs"),
            SettingsItem(name: "Posted Jobs", action: "goToPostedJobs"),
            //SettingsItem(name: "My Account", action: "")
            SettingsItem(name: "Archived Chats", action: "goToChats")
        ],
        [
            SettingsItem(name: "LinkedIn", action: "linkedin"),
            SettingsItem(name: "Facebook", action: "facebook")
        ],
        [
            //SettingsItem(name: "Invite Friends", action: ""),
            SettingsItem(name: "Terms of Use", action: "goToTerms"),
            SettingsItem(name: "Privacy Policy", action: "goToTerms"),
            SettingsItem(name: "Send Feedback", action: "goToFeedBack")
        ],
        [
            //SettingsItem(name: "Log Out", action: "goToLogin"),
            SettingsItem(name: "DELETE MY ACCOUNT", action: "goToLogin")
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

        BaseController().apiRequest(Alamofire.Method.GET, path: "users/me?params=user.status,user.facebook,user.linkedin", closure: { json in
            println(json)
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
                
                var social = SocialStatus(status: self.socialStatuses["linkedin"]!, and: data.action)
                social.delegate = self
                cell.accessoryView = social
                
            }else{
                cell.accessoryView = nil;
            }
            
        } else if(data.action == "facebook"){
            
            cell.imageView!.image = UIImage(named: "facebook_icon")
            
            if(self.socialStatuses.count > 0){
                
                var social = SocialStatus(status: self.socialStatuses["facebook"]!, and: data.action)
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
        return section == structure.count - 1 ? 0.01: 0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.01: 0
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.section == 3) {
            return 88;
        }else{
            return 44;
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let action = structure[indexPath.section][indexPath.row].action
        let name = structure[indexPath.section][indexPath.row].name
        if (count(action) <= 0) {
            return
        }
        
        if(name == "Privacy Policy"){
            isPolicy = true
        }else{
            isPolicy = false
        }

        if(action == "linkedin"){
        
        }else if(action == "facebook"){
        
            
        }else if(action == "goToLogin"){
            
            var alertview = UIAlertView(title: "Delete Account", message: "Are you sure you want to parmanently delete your account information, including jobs and chats?", delegate:self, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete")
            alertview.tag = 3
            alertview.show();
            
        }else{
            
            self.jobsSelected = action
            performSegueWithIdentifier(action, sender: self)
            
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // goToLogin
        if (segue.destinationViewController.isKindOfClass(LoginController)) {
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.logout()
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
                    
                    controller.title = "Posted Jobs"
                    controller.requestParams = "mine"
                    
                }
                
                if(self.jobsSelected == "goToSavedJobs"){
                
                    controller.title = "Saved Jobs"
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
            
            var alertview = UIAlertView(title: "Disconnect \(statusIdentifier)", message:"Are you sure you want to disconnect \(statusIdentifier)", delegate:self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
            alertview.tag = statusIdentifier == "facebook" ? 0 : 1
            alertview.show();
            
        }else{
            
            self.handleSocialAction(statusIdentifier)
        }
        
        
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if alertView.tag == 3 {
            
            if(buttonIndex == 1){
                
                MixPanelHandler.sendData("DeleteAcountAction")
                self.jobsSelected = "goToLogin"
                performSegueWithIdentifier("goToLogin", sender: self)
                
            }else{
                
                println("cancelled delete account")
                
            }
            
        }else{
        
            if(buttonIndex == 1){
                
                self.handleSocialAction(alertView.tag ==  0 ? "facebook" : "linkedin")
                
            }else{
                
                println("cancelled delete social")
                
            }
        
        }
  
        
    }
    
    
    func handleSocialAction(statusIdentifier:String){
        
        //Default Message
        var alert = UIAlertView(title: "", message: "", delegate: nil, cancelButtonTitle: "OK")
        
        if(statusIdentifier == "facebook"){
        
            self.socialhander!.configureFacebook(self.statusParent!.currentStatus!, completionHandler: { success in
                
                if(success){
                
                    self.statusParent!.updateStatus()
                    self.socialStatuses["facebook"] = self.statusParent!.currentStatus!
                    
                    
                    if(self.statusParent!.currentStatus!){
                      
                        alert.title = "Facebook Connected!"
                        alert.message = "You have successfully connected your Facebook account"
                        
                    }else{
                       
                        alert.title = "Facebook Disconnected!"
                        alert.message = "You have successfully disconnected your Facebook account"
                        
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
                        
                        alert.title = "LinkedIn Connected!"
                        alert.message = "You have successfully connected your LinkedIn account"
                        
                    }else{
                        
                        alert.title = "LinkedIn Disconnected!"
                        alert.message = "You have successfully disconnected your LinkedIn account"
                        
                    }
                    

                    alert.show()
                    self.table.reloadData();
                }
                
            })
        }
        
    }
    
}

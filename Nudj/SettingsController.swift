//
//  SettingsTableViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingsController: UIViewController, SegueHandlerType, UITableViewDataSource, UITableViewDelegate, SocialStatusDelegate {
    
    enum SegueIdentifier: String {
        case ShowProfile = "showYourProfile"
        case ShowStatusPicker = "showStatusPicker"
        case GoToLogin = "goToLogin"
        case GoToFeedBack = "goToFeedBack"
        case GoToSavedJobs = "goToSavedJobs"
        case GoToPostedJobs = "goToPostedJobs"
        case GoToChats = "goToChats"
    }
    
    enum CellAction {
        case ShowProfile, ChooseStatus, ShowSavedJobs, ShowPostedJobs, ShowChats, ToggleFacebook, GiveFeedback, DeleteAccount
        
        func segueIdentifier() -> SegueIdentifier? {
            switch self {
            case ShowProfile: return SegueIdentifier.ShowProfile
            case ChooseStatus: return SegueIdentifier.ShowStatusPicker
            case ShowSavedJobs: return SegueIdentifier.GoToSavedJobs
            case ShowPostedJobs: return SegueIdentifier.GoToPostedJobs
            case ShowChats: return SegueIdentifier.GoToChats
            case ToggleFacebook: return nil
            case GiveFeedback: return SegueIdentifier.GoToFeedBack
            case DeleteAccount: return SegueIdentifier.GoToLogin
            }
        }
        
        func title() -> String {
            let titles = Localizations.Settings.Title.self
            switch self {
            case ShowProfile: return titles.Profile
            case ChooseStatus: return titles.Status
            case ShowSavedJobs: return titles.SavedJobs
            case ShowPostedJobs: return titles.PostedJobs
            case ShowChats: return titles.Chats
            case ToggleFacebook: return titles.Facebook
            case GiveFeedback: return titles.Feedback
            case DeleteAccount: return titles.DeleteAccount
            }
        }
    }

    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    
    var statusButton = StatusButton()
    var socialStatuses = [String:Bool]() // TODO: use Enum not String
    
    let cellIdentifier = "SettingsCell"

    var socialhander :SocialHandlerModel?
    var statusParent :SocialStatus?
    let itemsArray: [[CellAction]] = [
        [
            .ShowProfile,
            .ChooseStatus,
            .ShowSavedJobs,
            .ShowPostedJobs,
            .ShowChats
        ],
        [
            .ToggleFacebook
        ],
        [
            .GiveFeedback
        ],
        [
            .DeleteAccount
        ]
    ]


    override func viewDidLoad() {
        super.viewDidLoad()

        table.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        versionNumberLabel.text = fullVersionNumber()
        self.socialhander = SocialHandlerModel()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MixPanelHandler.sendData("SettingsTabOpened")
        
        self.tabBarController?.tabBar.hidden = false

        // TODO: Ugh fix this singleton mess
        // TODO: API strings
        BaseController().apiRequest(.GET, path: "users/me?params=user.status,user.facebook,user.linkedin", closure: { json in
            if (json["data"]["status"] != nil && json["data"]["status"].stringValue != "") {
                self.statusButton.setTitleByIndex(json["data"]["status"].intValue)
            }
            self.socialStatuses = ["facebook": json["data"]["facebook"].boolValue ,"linkedin":json["data"]["linkedin"].boolValue]
            self.table.reloadData()
        })
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return itemsArray.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray[section].count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SettingsCell
        let action = itemsArray[indexPath.section][indexPath.row]

        cell.setTitle(action.title());

        if (indexPath.section == 3) {
            cell.alignCenter()
            cell.textLabel?.textColor = UIColor.redColor()
        } else {
            cell.alignLeft()
        }

        switch action {
        case .ChooseStatus:
            cell.accessoryView = self.statusButton
            cell.accessoryView?.userInteractionEnabled = false
            
        case .ToggleFacebook:
            cell.imageView!.image = UIImage(named: "facebook_icon")
            if (self.socialStatuses.count > 0) {
                let social = SocialStatus(connected: self.socialStatuses["facebook"]!, and: action)
                social.delegate = self
                cell.accessoryView = social;
            } else {
                cell.accessoryView = nil;
            }
            
        case .DeleteAccount:
            cell.accessoryView = nil
            cell.accessoryType = UITableViewCellAccessoryType.None
            
        default:
            cell.accessoryView = nil
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }

        return cell
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // TODO: magic numbers
        return 0.0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // TODO: magic numbers
        return 0.0
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: magic numbers        
        if (indexPath.section == 3) {
            return 88.0
        }else{
            return 44.0;
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let action = itemsArray[indexPath.section][indexPath.row]
        switch action {
        case .ToggleFacebook:
            break
            
        case .DeleteAccount:
            let localization = Localizations.Settings.Delete.self
            let alert = UIAlertController(title: localization.Title, message: localization.Body, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.preferredAction = cancelAction
            let deleteAction = UIAlertAction(title: Localizations.Settings.Delete.Button, style: .Destructive, handler: deleteAccount)
            alert.addAction(deleteAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        default:
            guard let segueIdentifier = action.segueIdentifier() else {
                fatalError("Invalid segue identifier \(action)")
            }
            performSegueWithIdentifier(segueIdentifier, sender: self)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowProfile:
            let controller = segue.destinationViewController as! GenericProfileViewController
            controller.type = .Own
            
        case .ShowStatusPicker:
            break
            
        case .GoToLogin:
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.deleteAccount(inViewController: segue.destinationViewController)
            
        case .GoToFeedBack:
            break
            
        case .GoToSavedJobs:
            let controller = segue.destinationViewController as! SavedPostedJobs
            controller.title = Localizations.Settings.Title.SavedJobs
            controller.requestParams = "liked"
            
        case .GoToPostedJobs:
            let controller = segue.destinationViewController as! SavedPostedJobs
            controller.title = Localizations.Settings.Title.PostedJobs
            controller.requestParams = "mine"
            
        case .GoToChats:
            let controller = segue.destinationViewController as! ChatListViewController
            controller.isArchive = true
        }
    }

    func didTap(socialStatus: SocialStatus) {
        self.statusParent = socialStatus;
        let statusIdentifier = socialStatus.statusIdentifier
        switch statusIdentifier {
        case .ToggleFacebook:
            let statusName = statusIdentifier.title()
            if(socialStatus.connected){
                let title = Localizations.Settings.Disconnect.Title.Format(statusName)
                let message = Localizations.Settings.Disconnect.Title.Body(statusName)
                let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                
                let disconnectAction = UIAlertAction(title: Localizations.Settings.Disconnect.Button, style: .Default) {
                    _ in
                    self.handleSocialAction(.ToggleFacebook)
                }
                alert.addAction(disconnectAction)
                
                alert.preferredAction = cancelAction
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.handleSocialAction(.ToggleFacebook)
            }
            break
            
        default:
            break
        }
    }
    
    func deleteAccount(_: UIAlertAction) {
        MixPanelHandler.sendData("DeleteAcountAction")
        performSegueWithIdentifier(.GoToLogin, sender: self)
    }
    
    func handleSocialAction(action: CellAction){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction
        
        if action == .ToggleFacebook {
            self.socialhander!.configureFacebook(self.statusParent!.connected, completionHandler: { 
                success in
                if(success){
                    self.statusParent!.toggleConnected()
                    self.socialStatuses["facebook"] = self.statusParent!.connected
                    if(self.statusParent!.connected){
                        alert.title = Localizations.Settings.Facebook.Connected.Title
                        alert.message = Localizations.Settings.Facebook.Connected.Body
                    }else{
                        alert.title = Localizations.Settings.Facebook.Disconnected.Title
                        alert.message = Localizations.Settings.Facebook.Disconnected.Body
                    }
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
}

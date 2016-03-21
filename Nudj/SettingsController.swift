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
        case ReportAnIssue = "reportAnIssue"
        case GoToFavoriteJobs = "goToFavoriteJobs"
        case GoToPostedJobs = "goToPostedJobs"
        case GoToChats = "goToChats"
        case ShowFAQ = "ShowFAQ"
        case ShowTerms = "showT&Cs"
        case ShowPrivacyPolicy = "showPrivacyPolicy"
    }
    
    enum CellAction {
        case ShowProfile, ChooseStatus, ShowFavoriteJobs, ShowPostedJobs, ShowChats, ToggleFacebook, ShowFAQ, ShowTerms, ShowPrivacyPolicy, GiveFeedback, ReportAnIssue, DeleteAccount, TestNotification
        
        func segueIdentifier() -> SegueIdentifier? {
            switch self {
            case ShowProfile: return SegueIdentifier.ShowProfile
            case ChooseStatus: return SegueIdentifier.ShowStatusPicker
            case ShowFavoriteJobs: return SegueIdentifier.GoToFavoriteJobs
            case ShowPostedJobs: return SegueIdentifier.GoToPostedJobs
            case ShowChats: return SegueIdentifier.GoToChats
            case ToggleFacebook: return nil
            case ShowFAQ: return SegueIdentifier.ShowFAQ
            case ShowTerms: return SegueIdentifier.ShowTerms
            case ShowPrivacyPolicy: return SegueIdentifier.ShowPrivacyPolicy
            case GiveFeedback: return SegueIdentifier.GoToFeedBack
            case ReportAnIssue: return SegueIdentifier.ReportAnIssue
            case DeleteAccount: return SegueIdentifier.GoToLogin
            case TestNotification: return nil
            }
        }
        
        func title() -> String {
            let titles = Localizations.Settings.Title.self
            switch self {
            case ShowProfile: return titles.Profile
            case ChooseStatus: return titles.Status
            case ShowFavoriteJobs: return titles.FavoriteJobs
            case ShowPostedJobs: return titles.PostedJobs
            case ShowChats: return titles.Chats
            case ToggleFacebook: return titles.Facebook
            case ShowFAQ: return titles.Faq
            case ShowTerms: return titles.Terms
            case ShowPrivacyPolicy: return titles.PrivacyPolicy
            case GiveFeedback: return titles.Feedback
            case ReportAnIssue: return titles.ReportIssue
            case DeleteAccount: return titles.DeleteAccount
            case TestNotification: return titles.TestNotification
            }
        }
    }

    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    
    var statusButton = StatusButton()
    var socialStatuses = [String:Bool]() // TODO: use Enum not String
    
    let cellIdentifier = "SettingsCell"
    
    var socialhander: SocialHandlerModel?
    var statusParent: SocialStatus?
    let itemsArray: [[CellAction]] = [
        [
            .ShowProfile,
            .ChooseStatus,
            .ShowFavoriteJobs,
            .ShowPostedJobs,
            .ShowChats,
        ],
        // temporarily hide facebook option until #33 is resolved
//        [
//            .ToggleFacebook
//        ],
        [
            .ShowFAQ,
            .ShowTerms,
            .ShowPrivacyPolicy,
        ],
        [
            .GiveFeedback,
            .ReportAnIssue,
            .TestNotification,
        ],
        [
            .DeleteAccount,
        ],
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
        let path = API.Endpoints.Users.me
        let params = API.Endpoints.Users.paramsForStatuses()
        BaseController().apiRequest(.GET, path: path, params: params, closure: { json in
            if (json["data"]["status"] != nil && json["data"]["status"].stringValue != "") {
                self.statusButton.setTitleByIndex(json["data"]["status"].intValue)
            }
            self.socialStatuses = ["facebook": json["data"]["facebook"].boolValue]
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let action = itemsArray[indexPath.section][indexPath.row]

        cell.textLabel!.text = action.title()
        cell.textLabel?.textColor = .blackColor()
        cell.accessoryView = nil
        cell.accessoryType = .DisclosureIndicator

        switch action {
        case .ChooseStatus:
            cell.accessoryView = self.statusButton
            cell.accessoryView?.userInteractionEnabled = false
            
        case .ToggleFacebook:
            cell.imageView!.image = UIImage(named: "facebook_icon")
            if (self.socialStatuses.count > 0) {
                let social = SocialStatus(connected: self.socialStatuses["facebook"]!, and: action)
                social.delegate = self
                cell.accessoryView = social
            }
            
        case .DeleteAccount:
            cell.textLabel?.textColor = .redColor()
            
        case .TestNotification:
            cell.accessoryType = .None
            
        default:
            break
        }

        return cell
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
            
        case .TestNotification:
            let api = API.sharedInstance
            if (api.token == nil) {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.registerForRemoteNotifications()
                // TODO: send a notification when application:didRegisterForRemoteNotificationsWithDeviceToken: received?
                break
            }
            api.request(.GET, path: API.Endpoints.Notifications.test)
            let localization = Localizations.Settings.NotificationTest.self
            let alertController = UIAlertController(title: localization.Title, message: localization.Body, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.preferredAction = cancelAction
            self.presentViewController(alertController, animated: true, completion: nil)
            
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
            let controller = segue.destinationViewController as! SendFeedBackViewController
            controller.loadViewIfNeeded()
            controller.title = Localizations.Settings.Title.Feedback
            controller.endpoint = API.Endpoints.Feedback.base
            controller.introText.text = Localizations.Settings.Feedback.Intro
            controller.paramWrapper = API.Endpoints.Feedback.params
            
        case .ReportAnIssue:
            let controller = segue.destinationViewController as! SendFeedBackViewController
            controller.loadViewIfNeeded()
            controller.title = Localizations.Settings.Title.ReportIssue
            controller.endpoint = API.Endpoints.ReportAbuse.base
            controller.introText.text = Localizations.Settings.Report.Intro
            controller.paramWrapper = API.Endpoints.ReportAbuse.params
            
        case .GoToFavoriteJobs:
            let controller = segue.destinationViewController as! SavedPostedJobs
            controller.title = Localizations.Settings.Title.FavoriteJobs
            controller.queryType = .Liked
            
        case .GoToPostedJobs:
            let controller = segue.destinationViewController as! SavedPostedJobs
            controller.title = Localizations.Settings.Title.PostedJobs
            controller.queryType = .Posted
            
        case .GoToChats:
            let controller = segue.destinationViewController as! ChatListViewController
            controller.isArchive = true
            
        case .ShowFAQ, .ShowTerms, .ShowPrivacyPolicy:
            break
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

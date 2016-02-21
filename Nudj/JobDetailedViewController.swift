//
//  JobDetailedViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class JobDetailedViewController: BaseController, SegueHandlerType, CreatePopupViewDelegate {
    
    enum SegueIdentifier: String {
        case GoToProfile = "GoToProfile"
        case AskForReferral = "AskForReferral"
        case EditJob = "EditJob"
    }
    
    @IBOutlet var jobTitleText: UILabel!
    @IBOutlet var hirerName: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var employerText: NZLabel!
    @IBOutlet var locationText: NZLabel!
    @IBOutlet var salaryText: NZLabel!
    @IBOutlet var bonusText: NZLabel!
    @IBOutlet weak var jobActive: UIButton!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var TextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var interestedBtn: UIButton!
    @IBOutlet weak var nudgeBtn: UIButton!
    @IBOutlet weak var askForReferralButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  
    @IBOutlet weak var skills: TokenView!
   
    var jobID: Int?
    var hirerID: Int?
    var currentUser: UserModel?
    var isOwnJob: Bool {
        get {
            return hirerID == currentUser?.id
        }
    }
    var isFavorite = false
    
    var popup: CreatePopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.layer.masksToBounds = false
        menuView.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        menuView.layer.shadowRadius = 2.0
        menuView.layer.shadowOpacity = 0.5
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        MixPanelHandler.sendData("JobDetailsOpened")
        self.tabBarController?.tabBar.hidden = true
        
        activitySpinner.startAnimating()
        self.requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestData(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let appColor = appDelegate.appColor
        let appBlueColor = appDelegate.appBlueColor
        
        let path = API.Endpoints.Jobs.byID(jobID!)
        let params = API.Endpoints.Jobs.paramsForDetail()
        API.sharedInstance.request(.GET, path: path, params: params, closure: { 
            json in
            self.populateView(json["data"], appColor: appColor, appBlueColor: appBlueColor)
            }) { 
                error in
                loggingPrint("Error -> \(error)")
                self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func populateView(content: JSON, appColor: UIColor, appBlueColor: UIColor) {
        // TODO: API strings
        isFavorite = content["liked"].boolValue
        conformFavoriteButton()
        
        interestedBtn.hidden = isOwnJob
        nudgeBtn.hidden = isOwnJob
        askForReferralButton.hidden = !isOwnJob
        
        if isOwnJob {
            navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Edit
        } else {
            navigationItem.rightBarButtonItem?.title = "..." // Localizations.Jobs.Button.Menu
        }
        
        // Update skills
        skills.editable = false
        skills.userInteractionEnabled = false
        var skillsArr:[String] = [];
        for i in content["skills"].arrayValue{
            skillsArr.append(i["name"].stringValue)
        }
        skills.fillTokens(skillsArr)
        
        jobTitleText.text = content["title"].stringValue
        jobTitleText.numberOfLines = 0
        jobTitleText.adjustsFontSizeToFitWidth = true
        jobTitleText.minimumScaleFactor = 0.2
        
        hirerName.text = content["user"]["name"].stringValue
        hirerID = content["user"]["id"].intValue
        
        descriptionText.scrollEnabled = false
        descriptionText.text = content["description"].stringValue
        
        let sizeThatFitsTextView:CGSize = descriptionText.sizeThatFits( CGSizeMake(descriptionText.frame.size.width, CGFloat.max) )
        TextViewHeightConstraint.constant = sizeThatFitsTextView.height;
        
        // Set job active or not active status
        self.jobActive.selected = content["active"].boolValue
        
        /** Using NZLABEL to style a UILabel to have multiple colors and fontsize **/
        
        // Employer Property
        let employer = content["company"].stringValue
        employerText.text = Localizations.Jobs.Employer.Format(employer)
        employerText.setFontColor(appColor, string:employer)
        
        // Location Property
        let location = content["location"].stringValue
        locationText.text = Localizations.Jobs.Location.Format(location)
        locationText.setFontColor(appColor, string:location)
        
        // Salary Property
        let salary = content["salary"].stringValue
        salaryText.text = Localizations.Jobs.Salary.Format(salary)
        salaryText.setFontColor(appColor, string:salary)
        
        // Referral Property
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 22)
        // TODO: use a proper number formatter
        let formattedBonus = "£" + content["bonus"].stringValue
        bonusText.text = Localizations.Jobs.Bonus.Format(formattedBonus)
        bonusText.setFont(boldFont, string: formattedBonus)
        bonusText.setFontColor(appBlueColor, string: formattedBonus)
        
        activitySpinner.stopAnimating()
    }

    @IBAction func topRightNavAction(sender: UIBarButtonItem) {
        if (sender.title == Localizations.Jobs.Button.Edit){
            editJob(sender)
        } else {
            toggleMenu(sender)
        }
    }
    
    @IBAction func editJob(sender: AnyObject) {
        MixPanelHandler.sendData("EditJobButtonClicked")
        performSegueWithIdentifier(.EditJob, sender: sender)
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        //
    }
    
    @IBAction func toggleFavoriteJob(sender: AnyObject) {
        let mixPanelTitle = isFavorite ? "UnfavoriteJob" : "FavoriteJob"
        let path = API.Endpoints.Jobs.likeByID(jobID!) 
        let method: API.Method = isFavorite ? .DELETE : .PUT
        MixPanelHandler.sendData(mixPanelTitle)
        API.sharedInstance.request(method, path: path, params: nil, closure: { 
            json in
            }) { 
                error in
                loggingPrint("Error -> \(error)")
        }
        isFavorite = !isFavorite
        conformFavoriteButton()
    }
    
    @IBAction func blockJob(sender: AnyObject) {
        guard let jobID = self.jobID else {return}
        let title = Localizations.Jobs.Block.Title
        let message = Localizations.Jobs.Block.Body
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction
        
        let blockAction = UIAlertAction(title: Localizations.Jobs.Block.Button, style: .Destructive) {
            _ in //
            let endpoint = API.Endpoints.Jobs.blockByID(jobID)
            MixPanelHandler.sendData("JobBlocked")
            let api = API.sharedInstance
            api.request(.POST, path: endpoint, closure: {
                json in
                // TODO: maybe filter out the offending job locally while waiting for the server to respond
            })
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(blockAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func reportHirer(sender: AnyObject) {
        guard let userId = self.hirerID, hirerName = hirerName.text else {return}
        let title = Localizations.Jobs.ReportHirer.Title
        let message = Localizations.Jobs.ReportHirer.Body
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction
        
        let blockAction = UIAlertAction(title: Localizations.Jobs.ReportHirer.Button(hirerName), style: .Destructive) {
            _ in //
            let endpoint = API.Endpoints.Users.reportByID(userId)
            MixPanelHandler.sendData("HirerReported")
            let api = API.sharedInstance
            api.request(.POST, path: endpoint, closure: {
                json in
                // TODO: maybe filter out the offending hirer's jobs locally while waiting for the server to respond
            })
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(blockAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .GoToProfile:
            let profileView = segue.destinationViewController as! GenericProfileViewController
            if isOwnJob {
                profileView.type = .Own
            } else {
                profileView.userId = self.hirerID!
                profileView.type = .Public
                profileView.preloadedName = hirerName.text
            }
            
        case .AskForReferral:
            registerForRemoteNotifications()
            let askView = segue.destinationViewController as! AskReferralViewController
            askView.jobId = Int(self.jobID!)
            askView.isNudjRequest = true
            
        case .EditJob:
            let addJobView = segue.destinationViewController as! AddJobController
            addJobView.jobId = Int(self.jobID!)
            addJobView.isEditable = true
        }        
    }
    
    @IBAction func interested(sender: AnyObject) {
        MixPanelHandler.sendData("InterestedButtonClicked")
        registerForRemoteNotifications()
        let localization = Localizations.Jobs.Interested.self
        if currentUser!.hasFullyCompletedProfile() {
            // The user has a complete profile so we can go ahead and post an application
            let alert = UIAlertController(title: localization.Alert.Title, message: localization.Alert.Body, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let sendAction = UIAlertAction(title: Localizations.General.Button.Send, style: .Default, handler: postJobApplication)
            alert.addAction(sendAction)
            alert.preferredAction = sendAction
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // The user needs to complete their profile before we can post an application
            let alert = UIAlertController(title: localization.NeedProfile.Title, message: localization.NeedProfile.Body, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let editProfileAction = UIAlertAction(title: localization.Button.EditProfile, style: .Default) {
                alertAction in
                self.editProfile(alertAction, requiredFields: [.Name, .Email, .Company, .Skills, .Position, .Bio, .Location], completionHandler: {
                    _ in
                    self.postJobApplication(alertAction)
                })
            }
            alert.addAction(editProfileAction)
            alert.preferredAction = editProfileAction
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func nudjAction(sender: AnyObject) {
        MixPanelHandler.sendData("ReferButtonClicked")
        if (currentUser?.name?.isEmpty ?? true) || (currentUser?.email?.isEmpty ?? true) {
            // user needs to supply at least name and email
            let localization = Localizations.Jobs.Nudj.self
            let alert = UIAlertController(title: localization.NeedProfile.Title, message: localization.NeedProfile.Body, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let editProfileAction = UIAlertAction(title: localization.Button.EditProfile, style: .Default) {
                alertAction in
                self.editProfile(alertAction, requiredFields: [.Name, .Email], completionHandler: {
                    _ in
                    self.askForReferral(sender)
                })
            }
            alert.addAction(editProfileAction)
            alert.preferredAction = editProfileAction
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            askForReferral(sender)
        }
    }
    
    @IBAction func askForReferral(sender: AnyObject) {
        performSegueWithIdentifier(.AskForReferral, sender: sender)
    }
    
    private func registerForRemoteNotifications() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.registerForRemoteNotifications()
    }
    
    func editProfile(alertAction: UIAlertAction, requiredFields: GenericProfileViewController.Fields, completionHandler: GenericProfileViewController.CompletionHandler) {
        guard let userID = currentUser?.id else {return}
        let genericProfileVC = GenericProfileViewController.instantiateWithUserID(userID, type: .Own, requiredFields: requiredFields, completionHandler: completionHandler)
        self.navigationController?.pushViewController(genericProfileVC, animated:true)
    }
    
    func postJobApplication(_: UIAlertAction) {
        let path = API.Endpoints.Nudge.apply
        let params = API.Endpoints.Nudge.paramsForApplication(jobID!)
        API.sharedInstance.request(.PUT, path: path, params: params, closure: {
            json in
            self.navigationController?.navigationBarHidden = true
            
            self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true)
            guard let popup = self.popup else {
                return
            }
            weak var weakSelf = self
            popup.bodyText(Localizations.Jobs.Interested.Confirmation.Body)
            popup.delegate = weakSelf
            self.view.addSubview(self.popup!)
            }) { 
                error in
                // TODO: better error handling
                loggingPrint("Error -> \(error)")
        }
    }
    
    private func conformFavoriteButton() {
        let newTitle = isFavorite ? Localizations.Jobs.Button.Unfavorite : Localizations.Jobs.Button.Favorite
        favoriteButton.titleLabel?.text = newTitle
    }
    
    func dismissPopUp() {
        self.popup!.removeFromSuperview()
        self.navigationController?.navigationBarHidden = false
        self.popup = nil
    }
}

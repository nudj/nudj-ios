//
//  JobDetailedViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class JobDetailedViewController: BaseController, SegueHandlerType, SharableMessageType, CreatePopupViewDelegate {
    
    enum SegueIdentifier: String {
        case GoToProfile = "GoToProfile"
        case EditJob = "EditJob"
    }
    
    static let storyboardID = "JobDetailedView"
    
    @IBOutlet var jobTitleText: UILabel!
    @IBOutlet var hirerName: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var employerText: UILabel!
    @IBOutlet var locationText: UILabel!
    @IBOutlet var salaryText: UILabel!
    @IBOutlet var bonusText: UILabel!
    @IBOutlet weak var jobActive: UIButton!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var menuHidingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuShowingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var TextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var interestedBtn: UIButton!
    @IBOutlet weak var nudgeBtn: UIButton!
    @IBOutlet weak var askForReferralButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
  
    @IBOutlet weak var skills: TokenView!
    
    let menuAnimationDuration: NSTimeInterval = 0.5
   
    var jobID: Int?
    var hirerID: Int?
    var currentUser: UserModel?
    var isOwnJob: Bool {
        get {
            return hirerID == currentUser?.id
        }
    }
    var isFavorite = false
    var menuShown: Bool {
        get{
            return menuShowingConstraint.priority > menuHidingConstraint.priority
        }
        
        set(newShown) {
            menuShowingConstraint.priority = newShown ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
            menuHidingConstraint.priority = newShown ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        }
    }
    
    var popup: CreatePopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(jobID != nil, "jobID should be configured")
        precondition(currentUser != nil, "currentUser should be configured")
        
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
    
    func requestData(){
        let path = API.Endpoints.Jobs.byID(jobID!)
        let params = API.Endpoints.Jobs.paramsForDetail()
        API.sharedInstance.request(.GET, path: path, params: params, closure: { 
            json in
            self.populateView(json["data"])
            }) { 
                error in
                loggingPrint("Error -> \(error)")
                self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func populateView(content: JSON) {
        // TODO: API strings
        let job = JobModel(json: content)
        
        isFavorite = content["liked"].boolValue
        conformFavoriteButton()
        
        interestedBtn.hidden = isOwnJob
        nudgeBtn.hidden = isOwnJob
        askForReferralButton.hidden = !isOwnJob
        
        navigationItem.rightBarButtonItem = isOwnJob ? editBarButton : menuBarButton
        
        // Update skills
        skills.editable = false
        skills.userInteractionEnabled = false
        skills.fillTokens(job.skills)
        
        jobTitleText.text = job.title
        jobTitleText.numberOfLines = 0
        jobTitleText.adjustsFontSizeToFitWidth = true
        jobTitleText.minimumScaleFactor = 0.2
        
        hirerName.text = content["user"]["name"].stringValue
        hirerID = content["user"]["id"].intValue
        
        descriptionText.scrollEnabled = false
        descriptionText.text = job.description
        
        // TODO: revise this to be UIStackView friendly
        let sizeThatFitsTextView:CGSize = descriptionText.sizeThatFits( CGSizeMake(descriptionText.frame.size.width, CGFloat.max) )
        TextViewHeightConstraint.constant = sizeThatFitsTextView.height;
        
        // Set job active or not active status
        self.jobActive.selected = job.active
        
        func formatLabel(label: UILabel, text: String, subText: String, attributes: [String: AnyObject]) {
            let attributedString = NSMutableAttributedString(string: text)
            let range = (text as NSString).rangeOfString(subText)
            attributedString.addAttributes(attributes, range: range)
            label.attributedText = attributedString
        }
        
        let colorAttributes = [NSForegroundColorAttributeName: ColorPalette.nudjGreen]
        
        let employer = job.company
        formatLabel(employerText, text: Localizations.Jobs.Employer.Format(employer), subText: employer, attributes: colorAttributes)
        
        let location = job.location
        formatLabel(locationText, text: Localizations.Jobs.Location.Format(location), subText: location, attributes: colorAttributes)
        
        let salary = job.salaryFreeText
        formatLabel(salaryText, text: Localizations.Jobs.Salary.Format(salary), subText: salary, attributes: colorAttributes)
        
        // Referral Property
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 22)!
        
        let formattedBonus = job.formattedBonus
        let boldBlueAttribs: [String: AnyObject] = [NSFontAttributeName: boldFont, NSForegroundColorAttributeName: ColorPalette.nudjBlue]
        bonusText.text = Localizations.Jobs.Bonus.Format(formattedBonus)
        formatLabel(bonusText, text: Localizations.Jobs.Bonus.Format(formattedBonus), subText: formattedBonus, attributes: boldBlueAttribs)
        
        activitySpinner.stopAnimating()
    }

    @IBAction func editJob(sender: AnyObject) {
        MixPanelHandler.sendData("EditJobButtonClicked")
        performSegueWithIdentifier(.EditJob, sender: sender)
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        let shown = !self.menuShown
        setMenuShown(shown, animated: true)
    }
    
    private func setMenuShown(shown: Bool, animated: Bool) {
        let duration: NSTimeInterval = animated ? menuAnimationDuration : 0.0
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(duration) {
            self.menuShown = shown
            self.view.layoutIfNeeded()
        }
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
        setMenuShown(false, animated: true)
    }
    
    @IBAction func blockJob(sender: AnyObject) {
        guard let jobID = self.jobID, hirerID = self.hirerID else {return}
        let title = Localizations.Jobs.Block.Title
        let message = Localizations.Jobs.Block.Body
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction
        
        let blockAction = UIAlertAction(title: Localizations.Jobs.Block.Button, style: .Destructive) {
            _ in
            self.setMenuShown(false, animated: true)
            let endpoint = API.Endpoints.Jobs.blockByID(jobID)
            MixPanelHandler.sendData("JobBlocked")
            let api = API.sharedInstance
            api.request(.POST, path: endpoint)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.user.blockedJobIDs.insert(jobID)
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(blockAction)
        
        let reportAction = UIAlertAction(title: Localizations.Jobs.Report.Button, style: .Destructive) {
            _ in
            self.setMenuShown(false, animated: true)
            let endpoint = API.Endpoints.Users.reportByID(hirerID)
            MixPanelHandler.sendData("HirerReported")
            let api = API.sharedInstance
            api.request(.POST, path: endpoint)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.user.blockedUserIDs.insert(hirerID)
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(reportAction)
        
        setMenuShown(false, animated: true)
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
            
        case .EditJob:
            let addJobView = segue.destinationViewController as! AddJobController
            addJobView.jobID = Int(self.jobID!)
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
        shareJob(jobID!, isOwnJob: isOwnJob)
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
        favoriteButton.selected = isFavorite
    }
    
    func dismissPopUp() {
        self.popup!.removeFromSuperview()
        self.navigationController?.navigationBarHidden = false
        self.popup = nil
    }
}

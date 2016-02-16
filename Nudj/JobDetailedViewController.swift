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
    
    // TODO: remove singleton access
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    @IBOutlet var jobTitleText: UILabel!
    @IBOutlet var authorName: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var employerText: NZLabel!
    @IBOutlet var locationText: NZLabel!
    @IBOutlet var salaryText: NZLabel!
    @IBOutlet var bonusText: NZLabel!
    @IBOutlet weak var jobActive: UIButton!
    
    @IBOutlet weak var TextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var interestedBtn: UIButton!
    @IBOutlet weak var nudgeBtn: UIButton!
    @IBOutlet weak var askForReferralButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  
    @IBOutlet weak var skills: TokenView!
   
    var jobID: Int?
    var userId: Int?
    var popup: CreatePopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileTap = UITapGestureRecognizer(target:self, action:"goToProfile")
        self.authorName.addGestureRecognizer(profileTap)
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
        let path = API.Endpoints.Jobs.likeByID(jobID!)
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
    
    func goToProfile(){
        self.performSegueWithIdentifier(.GoToProfile, sender: self)
    }
    
    func populateView(content:JSON){
        // TODO: API strings
        if appDelegate.user.id == content["user"]["id"].intValue {
            interestedBtn.hidden = true
            nudgeBtn.hidden = true
            askForReferralButton.hidden = false
        } else {
            interestedBtn.hidden = false
            nudgeBtn.hidden = false
            askForReferralButton.hidden = true
        }
        
        if appDelegate.user.id == content["user"]["id"].intValue {
            navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Edit
        } else if content["liked"].boolValue {
            // TODO: review this: I find it a confusing UX
            navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Saved
        } else {
            navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Save
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
        
        authorName.text = content["user"]["name"].stringValue
        userId = content["user"]["id"].intValue
        
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
        employerText.setFontColor(appDelegate.appColor, string:employer)
        
        // Location Property
        let location = content["location"].stringValue
        locationText.text = Localizations.Jobs.Location.Format(location)
        locationText.setFontColor(appDelegate.appColor, string:location)
        
        // Salary Property
        let salary = content["salary"].stringValue
        salaryText.text = Localizations.Jobs.Salary.Format(salary)
        salaryText.setFontColor(appDelegate.appColor, string:salary)
        
        
        // Referral Property
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 22)
        // TODO: use a proper number formatter
        let formattedBonus = "£" + content["bonus"].stringValue
        bonusText.text = Localizations.Jobs.Bonus.Format(formattedBonus)
        bonusText.setFont(boldFont, string: formattedBonus)
        bonusText.setFontColor(appDelegate.appBlueColor, string: formattedBonus)
        
        activitySpinner.stopAnimating()
    }

    @IBAction func topRightNavAction(sender: UIBarButtonItem) {
        // TODO: use something less fragile than selecting on the button title
        if (sender.title == Localizations.Jobs.Button.Save) {
            MixPanelHandler.sendData("SaveJobButtonClicked")
            let path = API.Endpoints.Jobs.likeByID(jobID!) 
            API.sharedInstance.request(.PUT, path: path, params: nil, closure: { json in
                loggingPrint("Job saved \(json)")
                self.navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Saved
                
                }) { 
                    error in
                    loggingPrint("Error -> \(error)")
            }
        } else if(sender.title == Localizations.Jobs.Button.Saved) {
            MixPanelHandler.sendData("SavedJobButtonClicked")
            let path = API.Endpoints.Jobs.likeByID(jobID!) 
            API.sharedInstance.request(.DELETE, path: path, params: nil, closure: { 
                json in
                loggingPrint("un save \(json)")
                self.navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Save
                }, errorHandler: { 
                    error in
                    loggingPrint("Error -> \(error)")
            })
        } else if (sender.title == Localizations.Jobs.Button.Edit){
            // Go to EditView
            MixPanelHandler.sendData("EditJobButtonClicked")
            performSegueWithIdentifier(.EditJob, sender: sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .GoToProfile:
            let profileView = segue.destinationViewController as! GenericProfileViewController
            if(self.userId! == appDelegate.user.id) {
                profileView.type = .Own
            } else {
                profileView.userId = self.userId!
                profileView.type = .Public
                profileView.preloadedName = authorName.text
            }
            
        case .AskForReferral:
            appDelegate.registerForRemoteNotifications()
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
        appDelegate.registerForRemoteNotifications()
        let localization = Localizations.Jobs.Interested.self
        let user = appDelegate.user
        if user.hasFullyCompletedProfile() {
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
        if (appDelegate.user.name?.isEmpty ?? true) || (appDelegate.user.email?.isEmpty ?? true) {
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
    
    func editProfile(alertAction: UIAlertAction, requiredFields: GenericProfileViewController.Fields, completionHandler: GenericProfileViewController.CompletionHandler) {
        let genericProfileVC = GenericProfileViewController.instantiateWithUserID(appDelegate.user.id ?? 0, type: .Own, requiredFields: requiredFields, completionHandler: completionHandler)
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
    
    func dismissPopUp() {
        self.popup!.removeFromSuperview()
        self.navigationController?.navigationBarHidden = false
        // TODO: investigate if we can now set self.popup to nil
    }
}

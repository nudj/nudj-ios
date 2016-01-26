//
//  JobDetailedViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class JobDetailedViewController: BaseController, SegueHandlerType, CreatePopupViewDelegate, TutorialViewDelegate {
    
    enum SegueIdentifier: String {
        case GoToProfile = "GoToProfile"
        case AskForReferral = "AskForReferral"
    }
    
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
    @IBOutlet weak var spaceBetween: NSLayoutConstraint!
    @IBOutlet weak var nudgeBtn: UIButton!
  
    @IBOutlet weak var skills: TokenView!
   
    var jobID:String?
    var userId:Int?
    var popup :CreatePopupView?;
    var spinner = UIActivityIndicatorView()
    var tutorial = TutorialView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileTap = UITapGestureRecognizer(target:self, action:"goToProfile")
        self.authorName.addGestureRecognizer(profileTap)
        
        tutorial.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        MixPanelHandler.sendData("JobDetailsOpened")
        self.tabBarController?.tabBar.hidden = true
        
        for subView in self.view.subviews {
            subView.hidden = true;
        }
        
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        spinner.startAnimating()
        spinner.center = self.view.center
        spinner.color = appDelegate.appColor
        self.view.addSubview(spinner)
        self.requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestData(){
        // TODO: API strings
        API.sharedInstance.get("jobs/\(self.jobID!)?params=job.title,job.company,job.liked,job.salary,job.active,job.description,job.skills,job.bonus,job.user,job.location,user.image,user.name,user.contact", params: nil, closure: { 
            json in
            self.populateView(json["data"])
            loggingPrint(json)
            
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
        // Configure right button
        // TODO: API strings
        if(appDelegate.user.id == content["user"]["id"].intValue){
            
            if appDelegate.shouldShowAskForReferralTutorial  {
               tutorial.starTutorial("tutorial-ask", view: self.view)
            }
            
            self.navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Edit
            self.interestedBtn.setTitle(Localizations.Jobs.Button.AskForReferral, forState: UIControlState.Normal)
            
            spaceBetween.constant = 0
            let constraint = NSLayoutConstraint(item: nudgeBtn, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
            nudgeBtn.addConstraint(constraint)
            
        } else if(content["liked"].boolValue){
            // TODO: review this: I find it a confusing UX
            self.navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Saved
            if appDelegate.shouldShowNudjTutorial  {
                tutorial.starTutorial("tutorial-nudge", view: self.view)
            }
        } else {
            self.navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Save
            if appDelegate.shouldShowNudjTutorial  {
                tutorial.starTutorial("tutorial-nudge", view: self.view)
            }
        }
        
        // Update skills
        self.skills.editable = false
        self.skills.userInteractionEnabled = false
        var skillsArr:[String] = [];
        for i in content["skills"].arrayValue{
            skillsArr.append(i["name"].stringValue)
        }
        self.skills.fillTokens(skillsArr)
        
        jobTitleText.text = content["title"].stringValue
        jobTitleText.numberOfLines = 0
        jobTitleText.adjustsFontSizeToFitWidth = true
        jobTitleText.minimumScaleFactor = 0.2
        
        authorName.text = content["user"]["name"].stringValue
        self.userId = content["user"]["id"].intValue
        
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
        
        spinner.removeFromSuperview()
        for subView in self.view.subviews {
            subView.hidden = false;
        }
    }

    @IBAction func topRightNavAction(sender: UIBarButtonItem) {
        // TODO: API strings
        // TODO: use something less fragile than selecting on the button title
        if (sender.title == Localizations.Jobs.Button.Save) {
            MixPanelHandler.sendData("SaveJobButtonClicked")
            API.sharedInstance.put("jobs/\(self.jobID!)/like", params: nil, closure: { json in
                loggingPrint("Job saved \(json)")
                self.navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Button.Saved
                
                }) { 
                    error in
                    loggingPrint("Error -> \(error)")
            }
        } else if(sender.title == Localizations.Jobs.Button.Saved) {
            MixPanelHandler.sendData("SavedJobButtonClicked")
            API.sharedInstance.request(API.Method.DELETE, path: "jobs/\(self.jobID!)/like", params: nil, closure: { 
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
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let navController = storyboard.instantiateViewControllerWithIdentifier("addJobNavigationController") as! UINavigationController
            
            let addJobView = navController.viewControllers[0] as! AddJobController
            addJobView.jobId = Int(self.jobID!)
            addJobView.isEditable = true
            self.presentViewController(navController, animated: true, completion: nil)
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
            AppDelegate.registerForRemoteNotifications()
            let askView = segue.destinationViewController as! AskReferralViewController
            askView.jobId = Int(self.jobID!)
            askView.isNudjRequest = true
            askView.isSlideTransition = true
        }        
    }
    
    @IBAction func interested(sender: AnyObject) {
        MixPanelHandler.sendData("InterestedButtonClicked")
        AppDelegate.registerForRemoteNotifications()
        let localization = Localizations.Jobs.Interested.self
        if(sender as? UIButton == self.interestedBtn){
            if appDelegate.user.completed {
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
                    self.performSegueWithIdentifier(.AskForReferral, sender: sender)
                })
            }
            alert.addAction(editProfileAction)
            alert.preferredAction = editProfileAction
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier(.AskForReferral, sender: sender)
        }
    }
    
    func editProfile(alertAction: UIAlertAction, requiredFields: GenericProfileViewController.Fields, completionHandler: GenericProfileViewController.CompletionHandler) {
        let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let genericProfileVC = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController
        genericProfileVC.userId = appDelegate.user.id ?? 0
        genericProfileVC.type = .Own
        genericProfileVC.requiredFields = requiredFields
        genericProfileVC.completionHandler = completionHandler
        
        self.navigationController?.pushViewController(genericProfileVC, animated:true)
    }
    
    func postJobApplication(_: UIAlertAction) {
        // TODO: API strings
        let params:[String:AnyObject] = ["job_id": "\(self.jobID!)"]
        API.sharedInstance.put("nudge/apply", params: params, closure: {
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
    
    func dismissTutorial() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // TODO: API strings
        // TODO: select on something less fragile than the button title
        if(self.navigationItem.rightBarButtonItem?.title == Localizations.Jobs.Button.Edit){
            UserModel.update(["settings":["tutorial":["create_job":false]]], closure: { 
                result in
                appDelegate.updateUserObject("AskForReferralTutorial", with:false)
                appDelegate.shouldShowAskForReferralTutorial = false
            })
        } else {
            UserModel.update(["settings":["tutorial":["open_job":false]]], closure: { 
                result in
                appDelegate.updateUserObject("NudjTutorial", with:false)
                appDelegate.shouldShowNudjTutorial = false
            })
        }
    }
}

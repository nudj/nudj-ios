//
//  JobDetailedViewController.swift
//  Nudge
//
//  Created by Antonio on 29/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class JobDetailedViewController: BaseController, CreatePopupViewDelegate, UIAlertViewDelegate, TutorialViewDelegate {
    
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
        self.performSegueWithIdentifier("GoToProfile", sender: self)
    }
    
    func populateView(content:JSON){
        // Configure right button
        if(appDelegate.user!.id == content["user"]["id"].intValue){
            
            if appDelegate.shouldShowAskForReferralTutorial  {
               tutorial.starTutorial("tutorial-ask", view: self.view)
            }
            
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.interestedBtn.setTitle("Ask for Referral", forState: UIControlState.Normal)
            
            spaceBetween.constant = 0
            let constraint = NSLayoutConstraint(item: nudgeBtn, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
            nudgeBtn.addConstraint(constraint)
            
        } else if(content["liked"].boolValue){
            self.navigationItem.rightBarButtonItem?.title = "Saved"
            if appDelegate.shouldShowNudjTutorial  {
                tutorial.starTutorial("tutorial-nudge", view: self.view)
            }
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Save"
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
        employerText.text = "Employer: " + content["company"].stringValue
        employerText.setFontColor(appDelegate.appColor, string:content["company"].stringValue)
        
        // Location Property
        locationText.text = "Location: " + content["location"].stringValue
        locationText.setFontColor(appDelegate.appColor, string:content["location"].stringValue)
        
        // Salary Property
        salaryText.text = "Salary: " + content["salary"].stringValue
        salaryText.setFontColor(appDelegate.appColor, string:content["salary"].stringValue)
        
        
        // Referral Property
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 22)
        bonusText.text = "Referral Bonus: £" + content["bonus"].stringValue
        bonusText.setFont(boldFont, string: "£" + content["bonus"].stringValue)
        bonusText.setFontColor(appDelegate.appBlueColor, string: "£" + content["bonus"].stringValue)
        
        spinner.removeFromSuperview()
        for subView in self.view.subviews {
            subView.hidden = false;
        }
    }

    @IBAction func topRightNavAction(sender: UIBarButtonItem) {
        if (sender.title == "Save") {
            MixPanelHandler.sendData("SaveJobButtonClicked")
            API.sharedInstance.put("jobs/\(self.jobID!)/like", params: nil, closure: { json in
                loggingPrint("Job saved \(json)")
                self.navigationItem.rightBarButtonItem?.title = "Saved"
                
                }) { 
                    error in
                    loggingPrint("Error -> \(error)")
            }
        } else if(sender.title == "Saved") {
            MixPanelHandler.sendData("SavedJobButtonClicked")
            API.sharedInstance.request(API.Method.DELETE, path: "jobs/\(self.jobID!)/like", params: nil, closure: { 
                json in
                loggingPrint("un save \(json)")
                self.navigationItem.rightBarButtonItem?.title = "Save"
                }, errorHandler: { 
                    error in
                    loggingPrint("Error -> \(error)")
            })
        } else if (sender.title == "Edit"){
            
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
        if let askView = segue.destinationViewController as? AskReferralViewController {
            
            MixPanelHandler.sendData("ReferButtonClicked")
            askView.jobId = Int(self.jobID!)
            askView.isNudjRequest = true
            askView.isSlideTransition = true
        }
        
        if let profileView = segue.destinationViewController as? GenericProfileViewController {
            if(self.userId! == appDelegate.user!.id) {
                profileView.type = .Own
            } else {
                profileView.userId = self.userId!
                profileView.type = .Public
                profileView.preloadedName = authorName.text
            }
        }
    }
    
    @IBAction func interested(sender: UIButton) {
        // TODO: localisation
        if(sender.titleLabel?.text == "INTERESTED"){
            //Go to INTERESTED
            MixPanelHandler.sendData("InterestedButtonClicked")
            let alertview = UIAlertView(title: "Are you sure?", message: "This will send a notification to the Hirer that you are interested in this position", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Send")
            alertview.show()
        } else {
            MixPanelHandler.sendData("AskForReferalButtonClicked")
            //Go to EditView
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let addJobView = storyboard.instantiateViewControllerWithIdentifier("AskReferralView") as! AskReferralViewController
            addJobView.jobId = Int(self.jobID!)
            addJobView.isNudjRequest = false
            addJobView.jobTitle = self.jobTitleText.text
            addJobView.isSlideTransition = true
            self.navigationController?.pushViewController(addJobView, animated:true);
        }
    }
    
    //MARK: Invite user
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.postRequest()
        }
    }
    
    func postRequest(){
        let params:[String:AnyObject] = ["job_id": "\(self.jobID!)"]
        
        API.sharedInstance.put("nudge/apply", params: params, closure: { 
            json in
            self.navigationController?.navigationBarHidden = true
            
            self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true)
            self.popup!.bodyText("The hirer has been notified")
            self.popup!.delegate = self
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
    }
    
    func dismissTutorial() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        
        if(self.navigationItem.rightBarButtonItem?.title == "Edit"){
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

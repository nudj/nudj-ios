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
import Alamofire

class JobDetailedViewController: BaseController, CreatePopupViewDelegate, UIAlertViewDelegate{
    
    var jobID:String?
    
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
    var popup :CreatePopupView?;
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = true
        self.requestData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func requestData(){
        
        API.sharedInstance.get("jobs/\(self.jobID!)?params=job.title,job.company,job.liked,job.salary,job.active,job.description,job.skills,job.bonus,job.user,job.location,user.image,user.name,user.contact", params: nil, closure: { json in
            
            self.populateView(json["data"])
            println(json)
            
        }) { error in
            
            println("Error -> \(error)")
            self.navigationController?.popViewControllerAnimated(true)
            
        }

    }
    
    
    func populateView(content:JSON){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        
        // Configure right button
        if(appDelegate.user!.id == content["user"]["id"].intValue){
            
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.interestedBtn.setTitle("Ask for Referral", forState: UIControlState.Normal)
            
            spaceBetween.constant = 0
            let constraint = NSLayoutConstraint(item: nudgeBtn, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
            nudgeBtn.addConstraint(constraint)
            
            
        }else if(content["liked"].boolValue){
        
            self.navigationItem.rightBarButtonItem?.title = "Saved"
            
            
        }else{
            
            self.navigationItem.rightBarButtonItem?.title = "Save"
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
        
        descriptionText.scrollEnabled = false
        descriptionText.text = content["description"].stringValue
        
        var sizeThatFitsTextView:CGSize = descriptionText.sizeThatFits( CGSizeMake(descriptionText.frame.size.width, CGFloat.max) )
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
        
    }

    @IBAction func topRightNavAction(sender: UIBarButtonItem) {
        
        if (sender.title == "Save"){
            
            API.sharedInstance.put("jobs/\(self.jobID!)/like", params: nil, closure: { json in
                
                    println("Job saved \(json)")
                    self.navigationItem.rightBarButtonItem?.title = "Saved"
                
                }) { error in
                    
                    println("Error -> \(error)")
            }
            
        }else if(sender.title == "Saved"){
         
            API.sharedInstance.request(Alamofire.Method.DELETE, path: "jobs/\(self.jobID!)/like", params: nil, closure: { json in
                
                println("un save \(json)")
                self.navigationItem.rightBarButtonItem?.title = "Save"
                
            }, errorHandler: { error in
                
                println("Error -> \(error)")
            })
            
        }else if (sender.title == "Edit"){
        
            //Go to EditView
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var addJobView = storyboard.instantiateViewControllerWithIdentifier("AddJobView") as! AddJobController
            addJobView.jobId = self.jobID?.toInt()
            addJobView.isEditable = true
            self.navigationController?.pushViewController(addJobView, animated:true);
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let askView = segue.destinationViewController as? AskReferralViewController {
            askView.jobId = self.jobID!.toInt()
            askView.isNudjRequest = true
        }
    }
    
    @IBAction func interested(sender: UIButton) {
    
        
        if(sender.titleLabel?.text == "INTERESTED"){
            //Go to INTERESTED
            
            var alertview = UIAlertView(title: "Are you sure?", message: "This will send a notification to the Hirer that you are interested in this position", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Send")
            alertview.show()
            
            
        }else{
            
            //Go to EditView
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var addJobView = storyboard.instantiateViewControllerWithIdentifier("AskReferralView") as! AskReferralViewController
            addJobView.jobId = self.jobID?.toInt()
            addJobView.isNudjRequest = false
            addJobView.jobTitle = self.jobTitleText.text
            self.navigationController?.pushViewController(addJobView, animated:true);
            
        }
        
    }
    
    //MARK :Invite user
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    
        if buttonIndex == 1 {
            
            self.postRequest()
            
        }
    }
    
    func postRequest(){
        
        let params:[String:AnyObject] = ["job_id": "\(self.jobID!)"]
        
        API.sharedInstance.put("nudge/apply", params: params, closure: { json in
            
            println("Job interested")
            self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
            self.popup!.bodyText("The hirer has been notified");
            self.popup!.delegate = self;
            self.view.addSubview(self.popup!);
            
            
            }) { error in
                
                println("Error -> \(error)")
        }

    }
    
    func dismissPopUp() {
        
        popup!.removeFromSuperview();
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

}

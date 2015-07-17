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

class JobDetailedViewController: BaseController {
    
    var jobID:String?
    
    @IBOutlet var jobTitleText: UILabel!
    @IBOutlet var authorName: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var employerText: NZLabel!
    @IBOutlet var locationText: NZLabel!
    @IBOutlet var salaryText: NZLabel!
    @IBOutlet var bonusText: NZLabel!
    
    @IBOutlet weak var skills: TokenView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestData();
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated);
        
        self.navigationController?.navigationBarHidden = false;
        
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
        }

    }
    
    
    func populateView(content:JSON){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        
        // Configure right button
        if(appDelegate.user!.id == content["user"]["id"].intValue){
            
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            
        }else if(content["liked"].boolValue){
        
            self.navigationItem.rightBarButtonItem?.title = "Saved"
            self.navigationItem.rightBarButtonItem?.enabled = false
            
        }else{
            
            self.navigationItem.rightBarButtonItem?.title = "Save"
        }
        
        // Update skills
        
        self.skills.editable = false
        self.skills.userInteractionEnabled = false
        
        var skillsArr:[String] = [];
        
        for i in content["skills"].array! {
            
            skillsArr.append(i["name"].stringValue)
            
        }
        
        self.skills.fillTokens(skillsArr)
        
        jobTitleText.text = content["title"].stringValue
        authorName.text = content["user"]["name"].stringValue
        descriptionText.text = content["description"].stringValue
        
        
        // Set job active or not active status
        
        
        /** Using NZLABEL to style a UILabel to have multiple colors and fontsize **/
        
        // Employer Property
        employerText.text = "Employer: " + content["company"].stringValue
        employerText.setFontColor(appDelegate.appColor, string:content["company"].stringValue)
        
        // Location Property
        locationText.text = "Location: " + content["location"].stringValue
        locationText.setFontColor(appDelegate.appColor, string:content["location"].stringValue)
        
        // Salary Property
        salaryText.text = "Salary: £" + content["salary"].stringValue
        salaryText.setFontColor(appDelegate.appColor, string:"£" + content["salary"].stringValue)
        
        
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
                    self.navigationItem.rightBarButtonItem?.enabled = false
                
                }) { error in
                    
                    println("Error -> \(error)")
            }
            
        }else if (sender.title == "Edit"){
        
            //Go to EditView
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var addJobView = storyboard.instantiateViewControllerWithIdentifier("AddJobView") as! AddJobController
            self.navigationController?.pushViewController(addJobView, animated:true);
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let askView = segue.destinationViewController as? AskReferralViewController {
            askView.jobId = self.jobID!.toInt()
        }
    }
    
    
    @IBAction func interested(sender: UIButton) {
    
        
    }
    

}

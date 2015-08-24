//
//  AddJobController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 30.04.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class AddJobController: UIViewController, CreatePopupViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate{

    var popup :CreatePopupView?
    var isEditable:Bool?
    var jobId:Int?
    

    @IBOutlet weak var scrollView: UIScrollView!
    var openSpace:CGFloat = 0;

    // Fields

    @IBOutlet weak var jobTitle: UITextField!
    @IBOutlet weak var jobIcon: UIImageView!

    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var jobDescriptionLabel: UILabel!
    @IBOutlet weak var jobDescriptionIcon: UIImageView!

    @IBOutlet weak var skills: TokenView!{
        didSet {
            skills.startEditClosure = scrollToSuperView
            skills.changedClosure = { _ in self.updateAssets() }
        }
    }
    
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var skillsIcon: UIImageView!

    @IBOutlet weak var salary: UITextField!
    @IBOutlet weak var salaryIcon: UIImageView!

    @IBOutlet weak var employer: UITextField!
    @IBOutlet weak var employerIcon: UIImageView!

    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var locationIcon: UIImageView!

    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var bonus: UITextField!

    @IBOutlet weak var topGreyBorder: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var bottomGreyBorder: UIView!

    override func viewDidLoad() {

        self.tabBarController?.tabBar.hidden = true
        skills.placeholderLabel = self.skillsLabel
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardChanged:", name: UIKeyboardDidChangeFrameNotification, object: nil);
        
        if(isEditable != nil && isEditable == true){
            
            self.navigationItem.rightBarButtonItem?.title = "Update"
            self.title = "Edit Job"
            
            self.deleteBtn.hidden = false
            self.topGreyBorder.hidden = false
            self.bottomGreyBorder.hidden = false
            
                API.sharedInstance.get("jobs/\(self.jobId!)?params=job.title,job.company,job.liked,job.salary,job.active,job.description,job.skills,job.bonus,job.user,job.location,user.image,user.name,user.contact", params: nil, closure: { json in
                    
                    self.prefillData(json["data"])
                    
                    }) { error in
                        
                        println("Error -> \(error)")
                }
                
            
        }
        

    }

    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = true
    }
    
    //ToDo :change to camel case
    @IBAction func PostAction(sender: AnyObject) {
    var item: UIBarButtonItem = sender as! UIBarButtonItem
    item.enabled = false
        
        self.resignFirstResponder()
        self.view.endEditing(true)
        
        //Scroll back to top
        scrollView.setContentOffset(CGPointMake(self.scrollView.contentOffset.x, 0), animated: true)
        
        if(self.checkFields()){
        
        var job = JobModel();
        job.title = jobTitle.text
        job.description = jobDescription.text
        job.skills = skills.tokens()!.map({token in return token.title})
        job.salary = salary.text
        job.company = employer.text
        job.location = location.text
        job.active = activeButton.selected
        job.bonus = bonus.text
            
            
            if(sender.title == "Update"){
                
                job.edit(self.jobId!, closure: { result in
                    if(result == true){
                        println ("did update")
                        self.navigationController?.navigationBarHidden = true
                        
                        self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"this_job_has-been_posted", withText: false);
                        self.popup?.delegate = self;
                        
                        self.view.addSubview(self.popup!)
                        
                    }else{
                        
                        self.navigationController?.navigationBarHidden = false
                        var alert = UIAlertView(title: "Failed to update", message: "Oops, something went wrong. Could not update the job details.", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                })
                
            }else{
                
                job.save { error, id in
                    if (error != nil) {
                        return
                    }
                    
                    self.jobId = id
                    self.navigationController?.navigationBarHidden = true

                    self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"this_job_has-been_posted", withText: false);
                    self.popup?.delegate = self;

                    self.view.addSubview(self.popup!)
                    
                    }
            }
            
        }else{
            
            var alert = UIAlertView(title: "Missing information", message: "Please fill in the fields marked with *", delegate: nil, cancelButtonTitle: "OK")
            alert.show();
            
        }
        
        item.enabled = true

    }
    
    func checkFields() -> Bool{
        
        if (jobTitle.text.isEmpty ){
            
            jobTitle.placeholder = self.appendRequired(jobTitle.placeholder!)
            return false
        }
        
        if (jobDescription.text.isEmpty){
         
            jobDescriptionLabel.text = self.appendRequired(jobDescriptionLabel.text!)
            return false
            
        }
        
        if (skills.tokens()!.count == 0){
            
            skillsLabel.text  = self.appendRequired(skillsLabel.text!)
            return false
        }
        
        
        if (salary.text.isEmpty){
            
            salary.placeholder = self.appendRequired(salary.placeholder!)
            return false
        }
        
        
        if (bonus.text.isEmpty){
         
            bonus.placeholder = self.appendRequired(bonus.placeholder!)
            return false
        }
        
        return true
    }
    
    func appendRequired(value:String) -> String{
        
        return value + " (Required)"
        
    }
    
    func prefillData(json:JSON){
        
        
        jobTitle.text = json["title"].stringValue
        jobDescriptionLabel.alpha = 0
        jobDescription.text = json["description"].stringValue
        salary.text = json["salary"].stringValue
        employer.text = json["company"].stringValue
        location.text = json["location"].stringValue
        
        // Update skills
        
        self.skills.editable = true
        self.skills.userInteractionEnabled = true
        
        var skillsArr:[String] = [];
        
        for i in json["skills"].arrayValue{
            
            skillsArr.append(i["name"].stringValue)
            
        }
        
        self.skills.fillTokens(skillsArr)

        activeButton.selected = json["active"].boolValue
        bonus.text = json["bonus"].stringValue
        updateAssets()
    }

    func updateAssets() {

        Common.automateUpdatingOfAssets(jobTitle, icon: jobIcon)
        Common.automateUpdatingOfAssets(jobDescription, icon: jobDescriptionIcon, label: jobDescriptionLabel)
        Common.automateUpdatingOfAssets(skills, icon: skillsIcon, label: skillsLabel)
        Common.automateUpdatingOfAssets(salary, icon: salaryIcon)
        Common.automateUpdatingOfAssets(employer, icon: employerIcon)
        Common.automateUpdatingOfAssets(location, icon: locationIcon)
    }

    // MARK: TextViewDelegate

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        scrollToSuperView(textView)

        return true
    }

    func textViewDidChange(textView: UITextView) {
        
        updateAssets()
    }

    // Hide keyboard on Return key and save the content
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }

        updateAssets()
        return true
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPointMake(self.scrollView.contentOffset.x, 0), animated: true)
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        scrollToSuperView(textField)
        
        if skills.tokens()?.count == 0 {
            skills.placeholderLabel?.hidden = false
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        updateAssets()
        return true
    }

    // MARK: Scroll Management

    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)

        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.layoutIfNeeded()
    }

    func keyboardChanged(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)

        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        self.openSpace = scrollView.contentSize.height - keyboardSize.height;
    }

    func scrollToSuperView(view: UIView) {
        if (view.superview == nil) {
            return;
        }

        var origin = view.superview!.frame.origin

        // TODO: Refactor this!!!!
        let maxOffset = scrollView.contentSize.height - self.openSpace - 100
        if (origin.y > maxOffset) {
            origin.y = maxOffset
        }

        scrollView.setContentOffset(origin, animated: true)
    }

    // Active/Inactive button

    @IBAction func toggleActiveStatus(sender: UIButton) {
        sender.selected = !sender.selected
    }


    //---------------------------------------------------------------------------------
    //--------------------------- COMMENTS KEYBOARD METHODS
    
    // MARK: -- COMMENTS KEYBOARD METHODS
    func keyboardWillShow(note: NSNotification){ }
    
    func keyboardWillHide(note: NSNotification){ }
    
    func dismissPopUp() {
        
        popup!.removeFromSuperview();
        if(self.navigationItem.rightBarButtonItem?.title == "Update"){
             MixPanelHandler.sendData("JobUpdated")
             self.closeCurrentView()
        }else{
            MixPanelHandler.sendData("NewJobAdded")
            performSegueWithIdentifier("showAskForReferal", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let refView = segue.destinationViewController as? AskReferralViewController {
            refView.jobId = self.jobId
            refView.isNudjRequest = false
            refView.jobTitle = self.jobTitle.text
        }
    }
    @IBAction func deleteAction(sender: UIButton) {
            
        var alert =  UIAlertView(title:"Delete job", message: "Are you sure you want to delete this job?", delegate: self, cancelButtonTitle: "NO",  otherButtonTitles: "YES")
        alert.show()
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 1 {
            
            API.sharedInstance.request(.DELETE, path: "jobs/\(self.jobId!)", params: nil, closure: { json in
                println("delete job -> jobs/\(self.jobId!)  -> \(json)")
                
                MixPanelHandler.sendData("JobDeleted")
                self.closeCurrentView()
                
            }, errorHandler: { error in
            
                var alert = UIAlertView(title: "Error", message:"Error deleting this job", delegate: nil, cancelButtonTitle:"OK")
                alert.show()
                
            })

            
        }
        
    }
    
    func closeCurrentView(){
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeAction(sender: UIBarButtonItem) {
       self.closeCurrentView()
    }
}

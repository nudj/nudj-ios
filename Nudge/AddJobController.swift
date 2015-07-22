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
class AddJobController: UIViewController, CreatePopupViewDelegate, UITextFieldDelegate, UITextViewDelegate{

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


    override func viewDidLoad() {

        self.tabBarController?.tabBar.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardChanged:", name: UIKeyboardDidChangeFrameNotification, object: nil);
        
        if(isEditable != nil && isEditable == true){
                
                API.sharedInstance.get("jobs/\(self.jobId!)?params=job.title,job.company,job.liked,job.salary,job.active,job.description,job.skills,job.bonus,job.user,job.location,user.image,user.name,user.contact", params: nil, closure: { json in
                    
                    self.prefillData(json["data"])
                    
                    }) { error in
                        
                        println("Error -> \(error)")
                }
                
            
        }
        

    }

    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    //ToDo :change to camel case
    @IBAction func PostAction(sender: AnyObject) {

        var job = JobModel();
        job.title = jobTitle.text
        job.description = jobDescription.text
        job.skills = skills.tokens()!.map({token in return token.title})
        job.salary = salary.text
        job.company = employer.text
        job.location = location.text
        job.active = activeButton.selected
        job.bonus = bonus.text

        job.save { error, id in
            if (error != nil) {
                return
            }
            
            self.jobDescription.resignFirstResponder()
            
            self.jobId = id

            self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"this_job_has-been_posted", withText: false);
            self.popup?.delegate = self;

            self.view.addSubview(self.popup!)
        }
        

    }
    
    func prefillData(json:JSON){
     
        jobTitle.text = json["title"].stringValue
        jobDescriptionLabel.alpha = 0
        jobDescription.text = json["description"].stringValue
        salary.text = json["salary"].stringValue
        employer.text = json["company"].stringValue
        location.text = json["location"].stringValue
        activeButton.selected = !activeButton.selected
        bonus.text = json["bonus"].stringValue
        
    }

    func updateAssets() {

        println(skills.tokens())
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
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        scrollToSuperView(textField)
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

        performSegueWithIdentifier("showAskForReferal", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let refView = segue.destinationViewController as? AskReferralViewController {
            refView.jobId = self.jobId
            refView.isNudjRequest = false
        }
    }
}

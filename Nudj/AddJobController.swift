//
//  AddJobController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class AddJobController: UIViewController, SegueHandlerType, CreatePopupViewDelegate, UITextFieldDelegate, UITextViewDelegate {

    enum SegueIdentifier: String {
        case ShowAskForReferral = "showAskForReferal"
    }
    
    var popup :CreatePopupView?
    var isEditable:Bool?
    var jobId:Int?

    @IBOutlet weak var scrollView: UIScrollView!
    var openSpace:CGFloat = 0.0;

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
    
    lazy var nonNumericCharacterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet

    override func viewDidLoad() {

        self.tabBarController?.tabBar.hidden = true
        skills.placeholder = self.skillsLabel.text ?? ""
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector:#selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        nc.addObserver(self, selector:#selector(keyboardChanged(_:)), name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        if(isEditable != nil && isEditable == true){
            
            self.navigationItem.rightBarButtonItem?.title = Localizations.Jobs.Add.Button.Update
            self.title = Localizations.Jobs.Add.Button.Edit
            
            self.deleteBtn.hidden = false
            self.topGreyBorder.hidden = false
            self.bottomGreyBorder.hidden = false
            
            let path = API.Endpoints.Jobs.byID(jobId!)
            let params = API.Endpoints.Jobs.paramsForDetail()
            API.sharedInstance.request(.GET, path: path, params: params, closure: {
                json in
                self.prefillData(json["data"])
                }) { error in
                    // TODO: handle error
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
    
    @IBAction func postJob(sender: AnyObject) {
        let item: UIBarButtonItem = sender as! UIBarButtonItem
        item.enabled = false
        
        self.resignFirstResponder()
        self.view.endEditing(true)
        
        //Scroll back to top
        scrollView.setContentOffset(CGPointMake(self.scrollView.contentOffset.x, 0), animated: true)
        
        if(self.checkFields()){
            let job = JobModel(
                title: jobTitle.text!,
                description: jobDescription.text,
                salaryFreeText: salary.text!,
                company: employer.text!,
                location: location.text!,
                bonusAmount: Int(bonus.text!) ?? 0,
                bonusCurrency: "GBP",
                active: activeButton.selected,
                skills: skills.tokens()!.map({token in return token.title})
            )
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.registerForRemoteNotifications()

            // TODO: select by something less fragile than the title
            if(sender.title == Localizations.Jobs.Add.Button.Update){
                job.edit(self.jobId!) { 
                    result in
                    if result == true {
                        self.showSuccessPopup()
                    } else {
                        self.postFailed()
                    }
                }
            } else {
                job.save() { 
                    error, id in
                    if error == nil {
                        self.jobId = id
                        self.showSuccessPopup()
                    } else {
                        self.postFailed()
                    }
                }
            }
        } else {
            let localization = Localizations.Jobs.Validation.Error.self
            let alert = UIAlertController(title: localization.Title, message: localization.Body, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.preferredAction = cancelAction
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        item.enabled = true
    }
    
    func showSuccessPopup() {
        self.navigationController?.navigationBarHidden = true
        let size = self.view.frame.size
        self.popup = CreatePopupView(x: 0, yCordinate: 0, width: size.width , height: size.height, imageName:"this_job_has-been_posted", withText: false);
        self.popup?.delegate = self;
        self.view.addSubview(self.popup!)
    }
    
    func postFailed() {
        self.navigationController?.navigationBarHidden = false
        
        let localization = Localizations.Jobs.Update.Error.self
        let alert = UIAlertController(title: localization.Title, message: localization.Body, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction
        self.presentViewController(alert, animated: true, completion: nil)
        
        self.closeCurrentView()
    }
    
    func checkFields() -> Bool{
        var result = true
        if (jobTitle.text!.isEmpty ){
            jobTitle.placeholder = self.appendRequired(jobTitle.placeholder!)
            result = false
        }
        
        if (jobDescription.text.isEmpty){
            jobDescriptionLabel.text = self.appendRequired(jobDescriptionLabel.text!)
            result = false
        }
        
        if (skills.tokens()!.count == 0){
            skillsLabel.text  = self.appendRequired(skillsLabel.text!)
            result = false
        }
        
        if (salary.text!.isEmpty){
            salary.placeholder = self.appendRequired(salary.placeholder!)
            result = false
        }
        
        if (bonus.text!.isEmpty){
            bonus.placeholder = self.appendRequired(bonus.placeholder!)
            result = false
        }
        
        return result
    }
    
    func appendRequired(value:String) -> String{
        return Localizations.Jobs.Validation.Required.Format(value)
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
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        updateAssets()
        switch textField {
        case bonus:
            let range = string.rangeOfCharacterFromSet(nonNumericCharacterSet)
            return range?.isEmpty ?? true
            
        default:
            return true
        }
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
        // TODO: select by something less fragile than the title
        if(self.navigationItem.rightBarButtonItem?.title == Localizations.Jobs.Add.Button.Update){
            MixPanelHandler.sendData("JobUpdated")
            self.closeCurrentView()
        }else{
            MixPanelHandler.sendData("NewJobAdded")
            performSegueWithIdentifier(.ShowAskForReferral, sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowAskForReferral:
            if let refView = segue.destinationViewController as? AskReferralViewController {
                refView.jobId = self.jobId
                refView.isNudjRequest = false
                refView.jobTitle = self.jobTitle.text
            }
        }
    }
    
    @IBAction func deleteAction(sender: UIButton) {
        let localization = Localizations.Jobs.Delete.Alert.self
        let alert = UIAlertController(title: localization.Title, message: localization.Body, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: Localizations.General.Button.Delete, style: .Destructive, handler: deleteJob)
        alert.addAction(deleteAction)
        alert.preferredAction = cancelAction
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteJob(_: UIAlertAction) {
        guard let jobId = jobId else {return}
        let path = API.Endpoints.Jobs.byID(jobId)
        API.sharedInstance.request(.DELETE, path: path, params: nil, closure: { 
            json in
            MixPanelHandler.sendData("JobDeleted")
            self.closeCurrentView()
            }, errorHandler: { 
                error in
                let localization = Localizations.Jobs.Delete.Error.self
              let alert = UIAlertController(title: localization.Title, message: localization.Body, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                alert.preferredAction = cancelAction
                self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func closeCurrentView(){
         self.navigationController?.popViewControllerAnimated(true)
    }
}

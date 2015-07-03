//
//  GenericProfileViewController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 27.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GenericProfileViewController: BaseController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    let msgTitle = "Choose Image Source"

    @IBOutlet var topLeftButton: UIBarButtonItem!
    @IBOutlet var topRightButton: UIBarButtonItem!
    
    @IBOutlet weak var statusButton: StatusButton! {
        didSet {
            statusButton.changeColor(UIColor.lightGrayColor())
        }
    }
    
    @IBOutlet weak var profilePhoto: AsyncImage! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: "pickLibrary")
            gesture.numberOfTapsRequired = 1
            profilePhoto.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backgroundImage: AsyncImage!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var skillsIcon: UIImageView!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var skills: TokenView! {
        didSet {
            skills.startEditClosure = scrollToSuperView
            skills.changedClosure = updateSkills
        }
    }

    @IBOutlet weak var aboutMeIcon: UIImageView!
    @IBOutlet weak var aboutMeField: UITextView!
    @IBOutlet weak var aboutMeFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var aboutMeLabel: UILabel!

    @IBOutlet weak var companyIcon: UIImageView!
    @IBOutlet weak var company: UITextField!

    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var locationIcon: UIImageView!

    @IBOutlet weak var position: UITextField!
    @IBOutlet weak var positionIcon: UIImageView!

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var emailIcon: UIImageView!


    var openSpace:CGFloat = 0
    var isEditable :Bool?
    var viewType :Int?
    var imagePicker = UIImagePickerController()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if(self.viewType != nil && self.viewType! == 1){
            //Sign up
            //no back button
            
            self.navigationItem.title = "Create Profile"
            self.topLeftButton.image = nil;
            
        }else if(self.viewType != nil && self.viewType! == 2){
            // Others 
            // change next button to favoutite button
            // back button enabled
            
            self.topRightButton.title = ""
            self.topRightButton.image = UIImage(named:"save");
            self.navigationItem.title = "Profile"
            
        }else{
            // My profile
            // no right button
            // back button enabled
            
            self.navigationItem.title = "My Profile"
            self.topRightButton.title = ""
        }
        
        self.registerNotification()

        // Get Local Values for the user
        UserModel.getLocal({user in
            if (user == nil) {
                return
            }

            self.nameLabel.text = user!.name
        })

        showUserData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func topRightButtonAction(sender: UIBarButtonItem) {
        
        if(self.viewType! == 2){
        self.topRightButton.image = nil
        self.topRightButton.image = UIImage(named:"saved");
        }
        
    }
    
    @IBAction func topLeftButtonAction(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func showUserData() {
        UserModel.getCurrent(["user.status", "user.name", "user.image", "user.skills", "user.about"], closure: { user in
            if let status = user.status {
                self.statusButton.setTitleByIndex(status)
                self.statusButton.changeColor(UIColor.whiteColor())
            }

            self.nameLabel.text = user.name
            self.aboutMeField.text = user.about
            self.showUserImage(user.image)

            if let skills = user.skills {
                self.skills.fillTokens(skills)
            }

            self.updateSkillsAssets()
            self.updateAboutAssets()
        })
    }

    func setInitialStatus(status: Bool) {
        if (status) {
            if (self.navigationItem.rightBarButtonItem != nil) {
//                self.navigationItem.rightBarButtonItem = self.nextButton
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    func makeThingsWhite() {
        nameLabel.textColor = UIColor.whiteColor()
        statusButton.changeColor(UIColor.whiteColor())
    }

    // MARK: User Update functions

    func updateUserName(userName: String) -> Void {

        UserModel.update(["name": userName], closure: { result in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.user!.name = userName
            appDelegate.pushUserData()
        })

    }

    // MARK: About

    func updateAbout(text: String) -> Void {
        println(["about": text])
        UserModel.update(["about": text], closure: {response in println(response)})
    }

    func updateAboutAssets() {
        let hasContent = count(aboutMeField.text) > 0

        aboutMeIcon.highlighted = hasContent
        aboutMeLabel.hidden = hasContent
    }

    // MARK: Skills

    func updateSkills(view:TokenView) {

        updateSkillsAssets()

        if (view.tokens() == nil || view.tokens()!.count <= 0) {
            UserModel.update(["skills": [String]()])
        } else {
            let skillsArray = view.tokens()!.map({token in return token.title})
            UserModel.update(["skills": skillsArray])
        }
    }

    func updateSkillsAssets() {
        let hasContent = skills.tokens()?.count > 0

        skillsIcon.highlighted = hasContent
        skillsLabel.hidden = hasContent
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case nameLabel:
            self.updateUserName(textField.text)
            textField.resignFirstResponder()
            break;

        case company:
            println("Update Company")
            break;

        default:
            println("Unknown field \(textField)")
        }

        return true
    }

    // MARK: TextViewDelegate

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        scrollToSuperView(textView)
        
        return true
    }

    func textViewDidChange(textView: UITextView) {
        let hasContent = count(textView.text) > 0
        aboutMeIcon.highlighted = hasContent
        aboutMeLabel.hidden = hasContent
    }

    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()

        updateAbout(textView.text!)

        return true
    }

    // Hide keyboard on Return key and save the content
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            updateAbout(textView.text!)
            return false
        }

        updateAboutAssets()
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

        self.openSpace = scrollView.frame.height - keyboardSize.height;
    }

    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.layoutIfNeeded()
    }

    func scrollToSuperView(view: UIView) {
        if (view.superview == nil) {
            return;
        }

        scrollView.setContentOffset(view.superview!.frame.origin, animated: true)
    }

    // MARK: Notifications Management

    func registerNotification() {
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    
    }


    // MARK: - Image management

    func pickLibrary() {
        var alert = UIAlertController(title: self.msgTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) {
            action -> Void in
            self.changeProfileImage(UIImagePickerControllerSourceType.Camera)
            })

        alert.addAction(UIAlertAction(title: "Library", style: UIAlertActionStyle.Default) {
            action -> Void in
            self.changeProfileImage(UIImagePickerControllerSourceType.SavedPhotosAlbum)
            })

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func changeProfileImage(source: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = source;
            imagePicker.allowsEditing = true

            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    func showUserImage(images: [String:String]) {
        if (images["profile"] != nil && count(images["profile"]!) > 0) {
            self.profilePhoto.downloadImage(images["profile"]!)
        }

        if (images["cover"] != nil && count(images["cover"]!) > 0) {
            self.backgroundImage.blur = true
            self.backgroundImage.downloadImage(images["cover"]!) { _ in
                self.makeThingsWhite()
            }
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })

        self.profilePhoto.startActivity()
        self.backgroundImage.startActivity()

        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.8).base64EncodedStringWithOptions(.allZeros)

        UserModel.update(["image": imageData], closure: { response in
            UserModel.getCurrent(["user.image"], closure: { user in
                self.showUserImage(user.image)
            })
        }) { _ in
            self.profilePhoto.stopActivity()
            self.backgroundImage.stopActivity()
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    @IBAction func continueAct(sender: AnyObject) {
        self.performSegueWithIdentifier("showMainScreen", sender: nil)
    }

    @IBAction func showStatusPicker() {
        self.performSegueWithIdentifier("showStatusPicker", sender: self)
    }

    @IBAction func HideImportView(sender: UIButton) {

    }

}

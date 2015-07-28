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

    @IBOutlet var topRightButton: UIBarButtonItem!
    
    @IBOutlet weak var statusButton: StatusButton! {
        didSet {
            statusButton.changeColor(UIColor.lightGrayColor())
        }
    }
    
    @IBOutlet weak var profilePhoto: AsyncImage! {
        didSet {
            profilePhoto.borderWidth = 3
            profilePhoto.borderAlpha = 0.2
            profilePhoto.prepare()

            let gesture = UITapGestureRecognizer(target: self, action: "pickLibrary")
            gesture.numberOfTapsRequired = 1
            profilePhoto.addGestureRecognizer(gesture)
        }
    }

    var preloadedName:String? = nil
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backgroundImage: AsyncImage! {
        didSet {
            // TODO: Find why this is not working in Designer
            backgroundImage.backgroundOverlay = 0.3
            backgroundImage.prepare()
        }
    }
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

    var isEditable:Bool = true {
        didSet {
            nameLabel.enabled = isEditable
            statusButton.enabled = isEditable
            skills.editable = isEditable
            aboutMeField.editable = isEditable
            company.enabled = isEditable
            location.enabled = isEditable
            position.enabled = isEditable
            email.enabled = isEditable
        }
    }

    var openSpace:CGFloat = 0
    var viewType :Int?
    var imagePicker = UIImagePickerController()

    var type:Type = Type.Public

    enum Type {
        case Own, Public, Initial
    }

    var userId:Int = 0

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = false
        
        prepareLayout();

        self.registerNotification()

        // Get Local Values for the user
        if (userId <= 0) {
            UserModel.getLocal({user in
                if (user == nil) {
                    return
                }

                self.nameLabel.text = user!.name
            })
        } else if preloadedName != nil {
            nameLabel.text = preloadedName
        }

        showUserData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.updateUserName(nameLabel.text)
        //Save when user press save

            switch self.type {
            case Type.Own: self.updateAllInformation()
                break;
            case Type.Initial: self.updateAllInformation()
                break;
            default:
            break;
            }
        
            
     
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
 

    // Layout

    func prepareLayout() {
        switch self.type {
        case Type.Own:
            self.topRightButton.title = "Save"
            self.navigationItem.title = "My Profile"
            isEditable = true;
            break;

        case Type.Initial:
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.topRightButton.title = "OK"
            self.navigationItem.title = "Create Profile"
            isEditable = true;
            break;

        case Type.Public: fallthrough
        default:
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.title = "Profile"
            self.email.superview!.hidden = true
            isEditable = false;
            skills.userInteractionEnabled = false
            profilePhoto.userInteractionEnabled = false
            break;
        }
    }

    // Navigatiopn Items

    @IBAction func topRightButtonAction(sender: UIBarButtonItem) {

        switch type {
        case .Initial:
            self.performSegueWithIdentifier("showMainScreen", sender: nil)
            break;
        case .Own:
            self.navigationController?.popViewControllerAnimated(true)
            break;
        default:
            break;
        }

    }

    // User Data Loding

    func showUserData() {
        UserModel.getById(userId, fields: ["user.status", "user.name", "user.image", "user.skills", "user.about", "user.company", "user.address", "user.position", "user.email"], closure: { response in

            let user = UserModel();
            user.updateFromJson(response["data"])

            if let status = user.status {
                self.statusButton.setTitleByIndex(status)
                self.statusButton.changeColor(UIColor.whiteColor())
            }

            if (user.name != nil && count(user.name!) > 0) {
                self.nameLabel.text = user.name
            } else if (self.preloadedName != nil) {
                self.nameLabel.text = self.preloadedName
                self.nameLabel.textColor = UIColor.blackColor()
            } else {
                self.nameLabel.text = ""
            }


            self.aboutMeField.text = user.about
            self.company.text = user.company
            self.location.text = user.address
            self.position.text = user.position
            self.email.text = user.email

            self.showUserImage(user.image)

            if let skills = user.skills {
                self.skills.fillTokens(skills)
            }

            self.updateAssets()
        })
    }

    func makeThingsWhite() {
        nameLabel.textColor = UIColor.whiteColor()
        statusButton.changeColor(UIColor.whiteColor())
    }

    // MARK: User Update functions

    func updateAllInformation(){
        
        UserModel.update(["name":nameLabel.text,"email":email.text,"position":position.text!,"address":location.text!,"company":company.text!], closure: { result in
            println("Save information : \(result)")
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.user!.name = self.nameLabel.text
            appDelegate.pushUserData()
            
            }, errorHandler: { error in
                println(error)
        })
        
        
    }
    
    
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

    func updateAssets() {
        Common.automateUpdatingOfAssets(aboutMeField, icon: aboutMeIcon, label: aboutMeLabel)
        Common.automateUpdatingOfAssets(skills, icon: skillsIcon, label: skillsLabel)
        Common.automateUpdatingOfAssets(company, icon: companyIcon)
        Common.automateUpdatingOfAssets(location, icon: locationIcon)
        Common.automateUpdatingOfAssets(position, icon: positionIcon)
        Common.automateUpdatingOfAssets(email, icon: emailIcon)
    }

    // MARK: Skills

    func updateSkills(view:TokenView) {

        updateAssets()

        if (view.tokens() == nil || view.tokens()!.count <= 0) {
            UserModel.update(["skills": [String]()])
        } else {
            let skillsArray = view.tokens()!.map({token in return token.title})
            UserModel.update(["skills": skillsArray])
        }
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case nameLabel:
            self.updateUserName(textField.text)
            break;

        case company:
            UserModel.update(["company": textField.text!], closure: { result in
                println("company: \(result)")
                }, errorHandler: { error in
                    println(error)
            })
            break;

        case location:
            UserModel.update(["address": textField.text!], closure: { result in
                println("address: \(result)")
            }, errorHandler: { error in
                println(error)
            })
            break;

        case position:
            UserModel.update(["position": textField.text!], closure: { result in
                println("position: \(result)")
                }, errorHandler: { error in
                    println(error)
            })
            break;

        case email:
            UserModel.update(["email": textField.text!], closure: { result in
                println("email: \(result)")
                }, errorHandler: { error in
                    println(error)
            })
            break;

        default:
            break
        }

        updateAssets()
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

    // MARK: TextViewDelegate

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        scrollToSuperView(textView)
        
        return true
    }

    func textViewDidChange(textView: UITextView) {
        updateAssets()
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
        if let vc = segue.destinationViewController as? MainTabBar {
            vc.navigationItem.setHidesBackButton(true, animated: false)
        }
    }

    @IBAction func showStatusPicker() {
        self.performSegueWithIdentifier("showStatusPicker", sender: self)
    }

}

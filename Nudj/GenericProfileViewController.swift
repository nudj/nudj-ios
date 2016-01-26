//
//  GenericProfileViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

class GenericProfileViewController: BaseController, SegueHandlerType, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    enum SegueIdentifier: String {
        case ShowMainScreen = "showMainScreen"
        case ShowStatusPicker = "showStatusPicker"
    }
    
    var hiddenFieldsCount = 0
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
            nameLabel?.enabled = isEditable
            statusButton?.enabled = isEditable
            skills?.editable = isEditable
            aboutMeField?.editable = isEditable
            company?.enabled = isEditable
            location?.enabled = isEditable
            position?.enabled = isEditable
            email?.enabled = isEditable
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
    var user:UserModel?

    
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

                self.user = user;
                self.nameLabel.text = user!.name
            })
        } else if preloadedName != nil {
            nameLabel.text = preloadedName
        }

        showUserData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        switch self.type {
        case .Initial, .Own:
            self.updateAllInformation()

        default:
            break
        }

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
 

    // Layout

    func prepareLayout() {
        switch self.type {
        case .Own:
            MixPanelHandler.sendData("MyProfileOpened")
            self.topRightButton.title = Localizations.General.Button.Save
            self.navigationItem.title = Localizations.Profile.Own.Title
            isEditable = true

        case .Initial:
            MixPanelHandler.sendData("CreateProfileOpened")
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.topRightButton.title = Localizations.General.Button.Ok
            self.navigationItem.title = Localizations.Profile.Create.Title
            isEditable = true

        case .Public:
            MixPanelHandler.sendData("ProfileOpened")
            self.topRightButton.title = nil
            self.navigationItem.title = Localizations.Profile.OtherPerson.Title
            self.email?.superview?.hidden = true
            isEditable = false;
            skills?.userInteractionEnabled = false
            profilePhoto.userInteractionEnabled = false
        }
    }

    // Navigatiopn Items

    @IBAction func topRightButtonAction(sender: UIBarButtonItem) {
        switch type {
        case .Initial:
            self.performSegueWithIdentifier(.ShowMainScreen, sender: nil)
            
        case .Own:
            MixPanelHandler.sendData("MyProfile_SaveButtonClicked")
            self.navigationController?.popViewControllerAnimated(true)
            
        case .Public:
            toggleFavourite()
        }
    }

    // User Data Loding

    func showUserData(){
        UserModel.getById(userId, fields: ["user.status", "user.name", "user.image", "user.skills", "user.about", "user.company", "user.address", "user.position", "user.email", "user.favourite"], closure: { response in

            let user = UserModel()
            user.updateFromJson(response["data"])
            
            /*if self.user != nil {
                self.user?.skills?.removeAll(keepCapacity: false)
            }*/
            
            self.user = user

            loggingPrint(response["data"])
            
            if let status = user.status {
                self.statusButton.setTitleByIndex(status)
            }

            if (!(user.name?.isEmpty ?? true)) {
                self.nameLabel.text = user.name
            } else if (self.preloadedName != nil) {
                self.nameLabel.text = self.preloadedName
                self.nameLabel.textColor = UIColor.blackColor()
            } else {
                self.nameLabel.text = ""
            }

            self.aboutMeField?.text = user.about
            self.company?.text = user.company
            self.location?.text = user.address
            self.position?.text = user.position
            self.email.text = user.email

            self.showUserImage(user.image)

            if let skills = user.skills {
                self.skills?.fillTokens(skills)
            }

            if (self.type == .Public && user.favourite != nil) {
                self.topRightButton.image = self.getFavouriteIcon(user.favourite!)
            }

            if (self.type == .Public) {
                self.hideEmptyViews()
            }

            self.updateAssets()
        }, errorHandler: { 
            error in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }

    func makeThingsWhite() {
        if (backgroundImage.image != nil) {
            nameLabel.textColor = UIColor.whiteColor()
            statusButton.changeColor(UIColor.whiteColor())
            backgroundImage.backgroundColor = nil
        }else{
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            backgroundImage.backgroundColor = appDelegate.appColor
            nameLabel.textColor = UIColor.whiteColor()
            statusButton.changeColor(UIColor.whiteColor())
        }
    }

    func getFavouriteIcon(status:Bool) -> UIImage? {
        return status ? UIImage(named: "favourited") : UIImage(named: "favourite")
    }

    func hideEmptyViews() {
        if (skills != nil && (skills.tokens() == nil || skills.tokens()!.count <= 0)) {
            hideView(skills.superview!)
            hiddenFieldsCount += 1
        }

        if (aboutMeField?.text.isEmpty ?? false) {
            hideView(aboutMeField.superview!)
            hiddenFieldsCount += 1
        }

        if (company?.text?.isEmpty ?? false) {
            hideView(company.superview!)
            hiddenFieldsCount += 1
        }

        if (location?.text?.isEmpty ?? false) {
            hideView(location.superview!)
            hiddenFieldsCount += 1
        }

        if (position?.text?.isEmpty ?? false) {
            hideView(position.superview!)
            hiddenFieldsCount += 1
        }
        
        if(hiddenFieldsCount == 5){
            let noContentImage = NoContentPlaceHolder()
            self.view.addSubview(noContentImage.alignInSuperView(self.view, imageTitle: "no_profile_content"))
            noContentImage.hidden = false
        }
    }

    func hideView(object:UIView, hideBorder:Bool = true) {
        for subView in object.subviews {
            subView.removeFromSuperview()
        }

        let height = NSLayoutConstraint(item: object, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
        object.addConstraint(height)
    }

    func hideBorderOfView(object:UIView) {
        var found = false
        for subView in object.superview!.subviews {
            if (found) {
                hideView(subView, hideBorder: false)
                return
            }

            if (subView == object) {
                found = true
            }
        }
    }

    // MARK: User Update functions
    
    func updateAllInformation(){
        UserModel.update([
            "name": nameLabel.text!, 
            "email": email.text!, 
            "position": position.text!, 
            "address": location.text!, 
            "company": company.text!, 
            "completed": true
            ], closure: { 
            result in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.user.name = self.nameLabel.text
            appDelegate.user.completed = true
            appDelegate.pushUserData()
        })
    }
    
    func updateUserName(userName: String) -> Void {
        UserModel.update(["name": userName], closure: { 
            result in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.user.name = userName
            appDelegate.pushUserData()
        })
    }

    func toggleFavourite() {
        if (userId != user?.id!) {
            loggingPrint("Inconsistency between userId and loaded user!")
            return
        }

        if let localUser = UserModel.getLocal() {
            if (localUser.id! == userId) {
                loggingPrint("You can't favourite yourself!")
                return;
            }

            user?.toggleFavourite({ result in
                if (result["status"].boolValue) {
                    if let user = self.user {
                        user.favourite = user.favourite == nil ? true : !user.favourite!
                        self.topRightButton.image = self.getFavouriteIcon(user.favourite!)
                        
                        MixPanelHandler.sendData(user.favourite == true ? "Profile_FavouriteAction" : "Profile_UnfavouriteAction")
                    }
                } else {
                    loggingPrint("Favourite Error: \(result)")
                }
            })
        }
    }

    
    // MARK: About

    func updateAbout(text: String) -> Void {
        UserModel.update(["about": text], closure: {_ in })
    }

    func updateAssets() {
        if (aboutMeField != nil) {
            Common.automateUpdatingOfAssets(aboutMeField, icon: aboutMeIcon, label: aboutMeLabel)
        }

        if (skills != nil) {
            Common.automateUpdatingOfAssets(skills, icon: skillsIcon, label: skillsLabel)
        }

        if (company != nil) {
            Common.automateUpdatingOfAssets(company, icon: companyIcon)
        }

        if (location != nil) {
            Common.automateUpdatingOfAssets(location, icon: locationIcon)
        }

        if (position != nil) {
            Common.automateUpdatingOfAssets(position, icon: positionIcon)
        }

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
            self.updateUserName(textField.text!)

        case company:
            UserModel.update(["company": textField.text!], closure: {_ in})

        case location:
            UserModel.update(["address": textField.text!], closure: {_ in})

        case position:
            UserModel.update(["position": textField.text!], closure: {_ in})

        case email:
            UserModel.update(["email": textField.text!], closure: {_ in})

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
        guard let superview = view.superview else {
            return;
        }

        scrollView.setContentOffset(superview.frame.origin, animated: true)
    }

    // MARK: Notifications Management

    func registerNotification() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

    // MARK: - Image management

    func pickLibrary() {
        // TODO: refactor with CreateProfileController
        let msgTitle = Localizations.Profile.New.ImageSource
        let alert = UIAlertController(title: msgTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: Localizations.Profile.ImageSource.Camera, style: UIAlertActionStyle.Default) {
            action -> Void in
            self.changeProfileImage(.Camera)
            })

        alert.addAction(UIAlertAction(title: Localizations.Profile.ImageSource.Library, style: UIAlertActionStyle.Default) {
            action -> Void in
            self.changeProfileImage(.PhotoLibrary)
            })

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func changeProfileImage(source: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
            imagePicker.delegate = self
            imagePicker.sourceType = source;
            imagePicker.allowsEditing = true

            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    func showUserImage(images: [String:String]) {
        if let profileImage = images["profile"] {
            if (!profileImage.isEmpty) {
                self.profilePhoto.downloadImage(images["profile"]!)
            }
        }

        if let coverImage = images["cover"] {
            if (!coverImage.isEmpty) {
                self.backgroundImage.blur = true
                self.backgroundImage.downloadImage(images["cover"]!)
            }
        }
        
        self.makeThingsWhite()
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)

        // Start activity to show that something is going on
        self.profilePhoto.startActivity()
        self.backgroundImage.startActivity()

        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        guard let imageData = UIImageJPEGRepresentation(image, 0.8)?.base64EncodedStringWithOptions([]) else {
            return
        }
        
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
        switch segueIdentifierForSegue(segue) {
        case .ShowMainScreen:
            if let vc = segue.destinationViewController as? MainTabBar {
                vc.navigationItem.setHidesBackButton(true, animated: false)
            }
        case .ShowStatusPicker:
            break
        }
    }

    @IBAction func showStatusPicker() {
        MixPanelHandler.sendData("MyProfile_StatusButtonClicked")
        self.performSegueWithIdentifier(.ShowStatusPicker, sender: self)
    }

}

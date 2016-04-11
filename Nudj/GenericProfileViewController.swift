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
    
    struct Fields: OptionSetType {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }
        
        static let Name = Fields(rawValue: 1 << 1)
        static let Email = Fields(rawValue: 1 << 2)
        static let Company = Fields(rawValue: 1 << 3)
        static let Skills = Fields(rawValue: 1 << 4)
        static let Position = Fields(rawValue: 1 << 5)
        static let Bio = Fields(rawValue: 1 << 6)
        static let Location = Fields(rawValue: 1 << 7)
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

            let gesture = UITapGestureRecognizer(target: self, action: #selector(pickLibrary))
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
            skills.changedClosure = skillsChanged
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

    var type:Type = Type.Public
    
    var requiredFields: Fields = []
    
    typealias CompletionHandler = ((GenericProfileViewController) -> Void)
    var completionHandler: CompletionHandler? = nil

    enum Type {
        case Own, Public, Initial
    }

    var userId: Int = 0
    var user: UserModel?
    
    static func instantiateWithUserID(userId: Int, type: Type, requiredFields: Fields, completionHandler: CompletionHandler) -> GenericProfileViewController {
        let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let genericProfileVC = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController
        genericProfileVC.userId = userId
        genericProfileVC.type = type
        genericProfileVC.requiredFields = requiredFields
        genericProfileVC.completionHandler = completionHandler
        return genericProfileVC
    }

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
        decoratePlaceholdersForRequiredFields()
        validate()
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

    // Navigation Items

    @IBAction func topRightButtonAction(sender: UIBarButtonItem) {
        switch type {
        case .Initial:
            self.updateAllInformation()
            self.performSegueWithIdentifier(.ShowMainScreen, sender: nil)
            
        case .Own:
            MixPanelHandler.sendData("MyProfile_SaveButtonClicked")
            self.updateAllInformation()
            self.navigationController?.popViewControllerAnimated(true)
            
        case .Public:
            toggleFavourite()
        }
        
        if let completionHandler = completionHandler {
            completionHandler(self)
        }
    }
    
    func validate() {
        topRightButton.enabled = self.hasEnoughData()
    }
    
    func hasEnoughData() -> Bool {
        if requiredFields.contains(.Name) && (nameLabel.text?.isEmpty ?? true) {
            return false
        }
        
        if requiredFields.contains(.Email) && (email.text?.isEmpty ?? true) {
            return false
        }
        
        if requiredFields.contains(.Company) && (company.text?.isEmpty ?? true) {
            return false
        }
        
        if requiredFields.contains(.Skills) && (skills.tokens()?.count ?? 0) == 0 {
            return false
        }
        
        if requiredFields.contains(.Position) && (position.text?.isEmpty ?? true) {
            return false
        }
        
        if requiredFields.contains(.Bio) && (aboutMeField.text?.isEmpty ?? true) {
            return false
        }
        
        if requiredFields.contains(.Location) && (location.text?.isEmpty ?? true) {
            return false
        }
        
        return true
    }
    
    func decoratePlaceholdersForRequiredFields() {
        decoratePlaceholder(nameLabel, identifier: .Name)
        decoratePlaceholder(email, identifier: .Email)
        decoratePlaceholder(company, identifier: .Company)
        decoratePlaceholder(position, identifier: .Position)
        decoratePlaceholder(location, identifier: .Location)
        decoratePlaceholder(skillsLabel, identifier: .Skills)
        decoratePlaceholder(aboutMeLabel, identifier: .Bio)
    }
    
    func decoratePlaceholder(field: UITextField, identifier: Fields) {
        field.placeholder = decoratedPlaceholder(field.placeholder, isRequired: requiredFields.contains(identifier))
    }
    
    func decoratePlaceholder(label: UILabel, identifier: Fields) {
        label.text = decoratedPlaceholder(label.text, isRequired: requiredFields.contains(identifier))
    }
    
    func decoratedPlaceholder(originalPlaceholder: String?, isRequired: Bool) -> String {
        var placeholder = originalPlaceholder ?? ""
        if placeholder.hasSuffix(" *") {
            placeholder.removeRange(placeholder.endIndex.advancedBy(-2) ..< placeholder.endIndex)
        }
        if isRequired {
            placeholder += " *"
        }
        return placeholder
    }

    // User Data Loding

    func showUserData(){
        UserModel.getById(userId, fields: UserModel.fieldsForProfile, closure: { 
                response in
                
                let user = UserModel()
                user.updateFromJson(response["data"])
                
                self.user = user
                
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
                self.validate()
            }, errorHandler: { 
                error in
                self.navigationController?.popViewControllerAnimated(true)
        })
    }

    func makeThingsWhite() {
        statusButton.changeColor(UIColor.whiteColor())
        nameLabel.textColor = UIColor.whiteColor()
        backgroundImage.backgroundColor = backgroundImage.image == nil ? ColorPalette.nudjGreen : nil
    }

    func getFavouriteIcon(status:Bool) -> UIImage? {
        return status ? UIImage(named: "favourited") : UIImage(named: "favourite")
    }

    private func hideEmptyViews() {
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
        updateSkills(skills)
        UserModel.update([
            "name": nameLabel.text!, 
            "about": aboutMeField.text!, 
            "email": email.text!, 
            "position": position.text!, 
            "address": location.text!, 
            "company": company.text!, 
            "completed": true
            ], 
            closure: { 
                result in
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let user = appDelegate.user
                user.name = self.nameLabel.text
                user.about = self.aboutMeField.text
                user.email = self.email.text
                user.position = self.position.text
                user.address = self.location.text
                user.company = self.company.text
                user.completed = true
                appDelegate.pushUserData()
        })
    }
    
    func toggleFavourite() {
        if (userId != user?.id!) {
            loggingPrint("Inconsistency between userId and loaded user!")
            return
        }
        
        let localUser = UserModel.getLocal()
        if (localUser.id! == userId) {
            loggingPrint("You can't favourite yourself!")
            return
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
    
    func skillsChanged(view:TokenView) {
        updateAssets()
        validate()
    }

    func updateSkills(view:TokenView) {
        if (view.tokens() == nil || view.tokens()!.count <= 0) {
            UserModel.update(["skills": [String]()])
        } else {
            let skillsArray = view.tokens()!.map({token in return token.title})
            UserModel.update(["skills": skillsArray])
        }
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        updateAssets()
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        scrollToSuperView(textField)
    }

    func textFieldDidEndEditing(textField: UITextField) {
        validate()
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
        validate()
    }

    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
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
        notificationCenter.addObserver(self, selector: #selector(keyboardWillBeShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: nameLabel, queue: nil) {_ in self.validate()}
        notificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: email, queue: nil) {_ in self.validate()}
        notificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: company, queue: nil) {_ in self.validate()}
        notificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: position, queue: nil) {_ in self.validate()}
        notificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: location, queue: nil) {_ in self.validate()}
    }

    // MARK: - Image management

    func pickLibrary() {
        let msgTitle = Localizations.Profile.New.ImageSource
        let alert = UIAlertController(title: msgTitle, message: nil, preferredStyle: .ActionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(UIAlertAction(title: Localizations.Profile.ImageSource.Camera, style: .Default) {
                action -> Void in
                self.changeProfileImage(.Camera)
                })
        }

        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: Localizations.Profile.ImageSource.Library, style: .Default) {
                action -> Void in
                self.changeProfileImage(.PhotoLibrary)
                })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: Localizations.Profile.ImageSource.SavedPhotosAlbum, style: .Default) {
                action -> Void in
                self.changeProfileImage(.SavedPhotosAlbum)
                })
        }

        if !alert.actions.isEmpty {
            self.presentViewController(alert, animated: true, completion: nil)            
        }
    }

    func changeProfileImage(source: UIImagePickerControllerSourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else {return}
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source;
        if source == .Camera && UIImagePickerController.isCameraDeviceAvailable(.Front) {
            imagePicker.cameraDevice = .Front            
        }
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
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
        // TODO: show the image immediately and put the encoding and upload on a background thread
        // Start activity to show that something is going on
        self.profilePhoto.startActivity()
        self.backgroundImage.startActivity()

        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        guard let imageData: String = UIImageJPEGRepresentation(image, 0.8)?.base64EncodedStringWithOptions([]) else {
            return
        }
        
        let imageParams = ["image": imageData]
        UserModel.update(imageParams, closure: { response in
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

//
//  CreateProfileControllerViewController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 12.06.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class CreateProfileController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var linkedIn: UIImageView!
    @IBOutlet weak var faceBookImage: UIImageView!
    
    let msgTitle = "Choose Image Source"

    @IBOutlet weak var image: AsyncImage! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: "pickLibrary")
            gesture.numberOfTapsRequired = 1
            image.addGestureRecognizer(gesture)
            image.circleShape = true
            image.prepare()
//            TODO: Find out why this is not working from xcode designer
        }
    }
    
    var imagePicker = UIImagePickerController()
    var socialhander:SocialHandlerModel?
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var status: StatusButton!

    @IBOutlet weak var nextButton: UIBarButtonItem!

    override func viewDidLoad() {
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("linkedinAction"))
        self.linkedIn.userInteractionEnabled = true
        self.linkedIn.addGestureRecognizer(tapGestureRecognizer)
        
        var tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:Selector("facebookAction"))
        self.faceBookImage.userInteractionEnabled = true
        self.faceBookImage.addGestureRecognizer(tapGestureRecognizer2)
        
        self.socialhander = SocialHandlerModel(viewController: self)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        showUserData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if !name.text.isEmpty {
            self.updateUserName(name.text)
        }
    }

    func showUserData() {
        UserModel.getCurrent(["user.status", "user.name", "user.image", "user.completed", "user.settings"], closure: { user in
        
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            
            if let settings :JSON = user.settings {
                println("server -> \( user.settings)")
                
                appDelegate.shouldShowAddJobTutorial = settings["tutorial"]["create_job"].boolValue
                appDelegate.shouldShowAskForReferralTutorial = settings["tutorial"]["post_job"].boolValue
                appDelegate.shouldShowNudjTutorial = settings["tutorial"]["open_job"].boolValue
               
                appDelegate.updateUserObject("AddJobTutorial", with: appDelegate.shouldShowAddJobTutorial)
                appDelegate.updateUserObject("AskForReferralTutorial", with: appDelegate.shouldShowAskForReferralTutorial)
                appDelegate.updateUserObject("NudjTutorial", with:  appDelegate.shouldShowNudjTutorial)

            }
            
            if (user.completed) {
                appDelegate.user!.completed = true
                appDelegate.pushUserData()
                appDelegate.changeRootViewController("mainNavigation")
            }

            if !user.isDefaultImage {
                self.image.downloadImage(user.image["profile"])
            }

            if let status = user.status {
                self.status.setTitleByIndex(status)
            }

            self.name.text = user.name

            self.checkIfUserMayProceed()
        })
    }

    func checkIfUserMayProceed() {
        let currentStatus = count(name.text) > 0 && status.isSelectedStatus()
        nextButton.enabled = currentStatus
    }
    

    // MARK: - Update user fields

    func updateUserName(userName: String) -> Void {

        UserModel.update(["name": userName], closure: { result in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.user!.name = userName
            appDelegate.pushUserData()
            self.checkIfUserMayProceed()
        })
        
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        checkIfUserMayProceed()

        return true
    }

    @IBAction func textFieldDidChange(sender: AnyObject) {
        checkIfUserMayProceed()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let popover = segue.destinationViewController as? StatusPicker {

            popover.preferredContentSize = CGSize(width: 200, height: 200)

        } else if let vc = segue.destinationViewController as? GenericProfileViewController {
            vc.type = .Initial
        }
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

    func showUserImage(url: String) {
        if (count(url) > 0) {
            self.image.downloadImage(url)
            self.checkIfUserMayProceed()
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })

        self.image.startActivity()

        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.8).base64EncodedStringWithOptions(.allZeros)

        UserModel.update(["image": imageData], closure: { response in

            // TODO: Remove this request when right url is returned after upload
            UserModel.getCurrent(["user.image"], closure: { user in
                self.showUserImage(user.image["profile"]!)
            })

        }, errorHandler: {_ in
            println("Error is catched!")
            self.image.stopActivity()
        })
    }

    //MARK: Linkedin
    
    func linkedinAction(){
        
        self.socialhander!.configureLinkedin(false, completionHandler: { success in
            
            if(success){
                
                self.performSegueWithIdentifier("showCreateProfileView", sender: self)
                
            }else{
                
                //Default Message
                var alert = UIAlertView(title: "Try Again", message: "OOPS, an error occured please try again!", delegate: nil, cancelButtonTitle: "OK")
                
            }
        })
    }
    
    
    //MARK: Facebook
    func facebookAction(){
        
        self.socialhander!.configureFacebook(false, completionHandler: { success in
            
            if(success){
                
                self.performSegueWithIdentifier("showCreateProfileView", sender: self)
                
            }else{
                
                //Default Message
                var alert = UIAlertView(title: "Try Again", message: "OOPS, an error occured please try again!", delegate: nil, cancelButtonTitle: "OK")
                
            }
        })
        
    }

}

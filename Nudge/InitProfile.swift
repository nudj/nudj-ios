//
//  InitProfile.swift
//  Nudge
//
//  Created by Lachezar Todorov on 27.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InitProfile: BaseController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, KSTokenViewDelegate, UITextViewDelegate {

    let msgTitle = "Chouse Image Source"

    @IBOutlet weak var statusButton: StatusButton!
    @IBOutlet weak var profilePhoto: AsyncImage!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backgroundImage: AsyncImage!
    @IBOutlet weak var skills: KSTokenView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aboutMeField: UITextView!

    var activeTextField:UIView? = nil
    var openSpace:CGFloat = 0

    var imagePicker = UIImagePickerController()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.registerNotification()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UITapGestureRecognizer(target: self, action: "pickLibrary")
        gesture.numberOfTapsRequired = 1
        self.profilePhoto.addGestureRecognizer(gesture)

        statusButton.changeColor(UIColor.lightGrayColor())

        skills.delegate = self
        skills.promptText = ""


        self.apiRequest(Alamofire.Method.GET, path: "users/me?params=user.status,user.name,user.image", closure: { json in

            self.nameLabel.text = json["data"]["name"].stringValue

            if (json["data"]["status"] != nil && json["data"]["status"].stringValue != "") {
                self.statusButton.setTitleByIndex(json["data"]["status"].intValue)
            }

            if (json["data"]["image"] != nil) {
                self.showUserImage(json["data"]["image"])
            }

        }, errorHandler: {error in })
    }
    
    @IBAction func continueAct(sender: AnyObject) {
        self.navigationController?.navigationItem.hidesBackButton = true
        self.performSegueWithIdentifier("showMainScreen", sender: nil)
    }

    @IBAction func showStatusPicker() {
        self.performSegueWithIdentifier("showStatusPicker", sender: self)
    }

    @IBAction func HideImportView(sender: UIButton) {
        
    }

    func makeThingsWhite() {
        nameLabel.textColor = UIColor.whiteColor()
        statusButton.changeColor(UIColor.whiteColor())
    }

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

    func showUserImage(json: JSON) {
        if (json["profile"] != nil && count(json["profile"].stringValue) > 0) {
            self.profilePhoto.downloadImage(json["profile"].stringValue)
        }

        if (json["cover"] != nil && count(json["cover"].stringValue) > 0) {
            self.backgroundImage.blur = true
            self.backgroundImage.downloadImage(json["cover"].stringValue) { _ in
                self.makeThingsWhite()
            }
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })

        self.profilePhoto.startActivity()
        self.backgroundImage.startActivity()

        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.8).base64EncodedStringWithOptions(.allZeros)

        self.apiUpdateUser(["image": imageData], closure: { json in
            self.apiRequest(.GET, path: "users/me?params=user.image", closure: { imageResponse in
                self.showUserImage(imageResponse["data"]["image"])
            })
        })
    }

    func updateUserName(userName: String) -> Void {

        self.apiRequest(.PUT, path: "users", params: ["name": userName], closure: { _ in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.user!.name = userName
            appDelegate.pushUserData()
        })
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.updateUserName(textField.text)

        return true
    }

    // MARK: UITextViewDelegate

    func textViewDidBeginEditing(textView: UITextView) {
        activeTextField = textView
        self.scrollToField()
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        println(textField)
        if (textField == nameLabel) {
            self.updateUserName(textField.text)
        } else {
            activeTextField = textField
        }
    }

    // MARK: KSTokenViewDelegate

    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        self.apiRequest(Method.GET, path: "skills/suggest/" + string, closure: { result in
            var data: Array<String> = result["data"].arrayObject as! Array<String>
            println(data)
            completion!(results: data)
        })
    }

    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }

    func tokenViewDidBeginEditing(tokenView: KSTokenView) {
        activeTextField = tokenView
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

        println("scrollView", scrollView.frame.height)
        println("Keyboard", keyboardSize.height)

        self.scrollToField()
    }

    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    func scrollToField() {
        if (activeTextField == nil) {
            return;
        }

        scrollView.scrollRectToVisible(activeTextField!.superview!.frame, animated:true)
    }

    // MARK: Notifications Management

    func registerNotification() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardDidChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

}

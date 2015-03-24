//
//  InitProfile.swift
//  Nudge
//
//  Created by Lachezar Todorov on 27.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

class InitProfile: BaseController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    let msgTitle = "Chouse Image Source"

    @IBOutlet weak var statusButton: StatusButton!
    @IBOutlet weak var profilePhoto: AsyncImage!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var backgroundImage: AsyncImage!


    var imagePicker = UIImagePickerController()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UITapGestureRecognizer(target: self, action: "pickLibrary")
        gesture.numberOfTapsRequired = 1
        self.profilePhoto.addGestureRecognizer(gesture)

        statusButton.changeColor(UIColor.lightGrayColor())

        self.apiRequest(.GET, path: "users/me?params=user.status,user.name,user.image", closure: { json in

            self.nameLabel.text = json["data"]["name"].stringValue

            if (json["data"]["status"] != nil && json["data"]["status"].stringValue != "") {
                self.statusButton.setTitle(json["data"]["status"].intValue)
            }

            if (json["data"]["image"] != nil) {
                self.showUserImage(json["data"]["image"])
            }

        }, errorHandler: {error in })

        Contacts().getContactNames()
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

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let userName = textField.text

        self.apiRequest(.PUT, path: "users", params: ["name": userName], closure: {
            _ in

            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
            appDelegate.user!.name = userName
            appDelegate.pushUserData()

        })
        return true
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
        if (json["profile"] != nil && countElements(json["profile"].stringValue) > 0) {
            self.profilePhoto.downloadImage(json["profile"].stringValue)
        }

        if (json["cover"] != nil && countElements(json["cover"].stringValue) > 0) {
            self.backgroundImage.blur = true
            self.backgroundImage.downloadImage(json["cover"].stringValue) { _ in
                self.makeThingsWhite()
            }
        }
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })

        self.profilePhoto.startActivity()
        self.backgroundImage.startActivity()

        let imageData = UIImageJPEGRepresentation(image, 0.8).base64EncodedStringWithOptions(.allZeros)

        self.apiUpdateUser(["image": imageData], closure: { json in
            self.apiRequest(.GET, path: "users/me?params=user.image", closure: { imageResponse in
                self.showUserImage(imageResponse["data"]["image"])
            })
        })
    }

}

//
//  LoginController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 26.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import UIKit
import AddressBook
import SwiftyJSON

class LoginController: BaseController {

    let msgTitle = "Refer anyone in your phone"
    let msgContent = "you will be able to text and refer anyone in your contacts"

    var code = ""
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCode: UITextField!

    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)

        phoneField.becomeFirstResponder()
        self.showLoginButton()

        self.changeNavigationBar(true)
    }

    @IBAction func loginAct(sender: UIButton) {

        // Hide button to prevent multiple clicks
        self.hideLoginButton()

        let phoneNumber = self.getFormattedNumber()

        if (count(phoneNumber) <= 8) {
            showSimpleAlert("Phone field is required.")
            showLoginButton()
            return;
        }

        println("Login with phone: " + phoneNumber)

        let params: [String: AnyObject] = ["phone": phoneNumber, "country_code": "GB"]

        API.sharedInstance.post("users", params: params, closure: { response in

            self.code = response["data"]["code"].stringValue

            if (count(self.code) <= 0) {
                self.showUnknownError()
                return
            }

            if (self.appDelegate.contacts.isAuthorized()) {
                self.proceed()
            } else {
                self.askForAddressBookPermission()
            }
        })
    }

    func showLoginButton() {
        self.loginButton.alpha = 1
        self.loginButton.enabled = true
    }

    func hideLoginButton() {
        self.loginButton.alpha = 0
        self.loginButton.enabled = false
    }

    override func showUnknownError() {
        self.showLoginButton()

        super.showUnknownError()
    }

    func askForAddressBookPermission() {
        var alert = UIAlertController(title: self.msgTitle, message: self.msgContent, preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: "Not Now", style: UIAlertActionStyle.Cancel) {
            action -> Void in
            self.appDelegate.showContactsAccessView()
            })

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            action -> Void in
            self.getContactListPermission()
            })

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func proceed() {
        self.performSegueWithIdentifier("showVerifyView", sender: self)
    }

    func getContactListPermission() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined)
        {
            NSLog("requesting access...")
            var emptyDictionary: CFDictionaryRef?
            var addressBook: ABAddressBook = ABAddressBookCreateWithOptions(emptyDictionary, nil).takeRetainedValue()

            ABAddressBookRequestAccessWithCompletion(addressBook, {success, error in
                println(success, error)

                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    if (success && error == nil) {
                        self.proceed()
                        return
                    }

                    NSLog("Unable to request access")
                    self.appDelegate.contacts.isAuthorized()
                })
            })
        }
        else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            NSLog("access denied")
            self.appDelegate.contacts.isAuthorized()
        }
        else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            NSLog("access granted")
            self.proceed()
        }
    }

    func getCleanNumber(number: String? = nil) -> String {
        let value = number == nil ? phoneField.text : number

        if (count(value) <= 0) {
            return "";
        }

        let index = advance(value.startIndex, 1)

        if (value.substringToIndex(index) == "0") {
            return self.getCleanNumber(number: value.substringFromIndex(index))
        } else {
            return value
        }
    }

    func getFormattedNumber() -> String {
        return self.countryCode.text + self.getCleanNumber(number: self.phoneField.text)
    }

    // MARK: - Navigation bar

    func changeNavigationBar(hidden: Bool) {
        if let nav = self.navigationController {
            nav.navigationBarHidden = hidden
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        self.changeNavigationBar(false)

        if let verify = segue.destinationViewController as? VerifyViewController {
            verify.setValue(self.getFormattedNumber(), forKey: "phoneNumber")
            verify.code = self.code
        }
    }
}
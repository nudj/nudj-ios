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

    var addressBookAccess = false
    var code = ""

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

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

            if (appDelegate.contacts.isAuthorized()) {
                self.proceed(status: true)
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
            self.proceed( status: false)
            })

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            action -> Void in
            self.getContactListPermission()
            })

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func proceed(status: Bool = true) {
        self.markAuthorizationStatus(status)
        self.performSegueWithIdentifier("showVerifyView", sender: self)
    }

    func proceedWithError() {
        self.showSimpleAlert("Unable to get Contacts!", action: { (a) -> Void in
            self.proceed(status: false)
        })
    }

    func markAuthorizationStatus(status: Bool) {
        self.addressBookAccess = status
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
                        self.proceed(status: true)
                        return
                    }

                    NSLog("Unable to request access")
                    self.proceedWithError()
                })
            })
        }
        else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            NSLog("access denied")
            self.proceedWithError()
        }
        else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            NSLog("access granted")
            self.proceed(status: true)
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
            verify.setValue(self.addressBookAccess, forKey: "addressBookAccess")
            verify.code = self.code
        }
    }
}
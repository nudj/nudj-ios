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

class LoginController: BaseController, CountrySelectionPickerDelegate, UITextFieldDelegate {

    let msgTitle = "Refer anyone in your phone"
    let msgContent = "you will be able to text and refer anyone in your contacts"
    
    var countrySelectionView = CountrySelectionPicker()
    var code = "GB"
    var isPrivacy:Bool?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var selectCountryLabel: UILabel!
    @IBOutlet weak var termsLiink: UILabel!
    @IBOutlet weak var privacyLink: UILabel!

    override func viewDidLoad() {
        
        self.selectCountryLabel.userInteractionEnabled = true
        var tap = UITapGestureRecognizer(target:self, action:"showCountryList")
        self.selectCountryLabel.addGestureRecognizer(tap)
        
        self.countrySelectionView.delegate = self;
        
        var policyTap = UITapGestureRecognizer(target:self, action:"showPolicy")
        self.privacyLink.addGestureRecognizer(policyTap)
        
        
        var termstap = UITapGestureRecognizer(target:self, action:"showTerms")
        self.termsLiink.addGestureRecognizer(termstap)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)

        phoneField.becomeFirstResponder()
        self.showLoginButton()

        self.changeNavigationBar(true)
    }

    func showCountryList(){
        
        self.phoneField.resignFirstResponder()
        
        if self.countrySelectionView.isCreated == false{
            self.view.addSubview(self.countrySelectionView.createDropActionSheet(self.phoneField.frame.origin.y + self.phoneField.frame.size.height+5, width: view.frame.size.width))
        }
        
        self.countrySelectionView.showAction()
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

        let params: [String: AnyObject] = ["phone": phoneNumber, "country_code": code]

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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if self.countrySelectionView.isCreated == true && self.countrySelectionView.hidden == false{
            
            self.countrySelectionView.doneAction()
            println("hide picker")
            
        }
        
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
    
    func showPolicy(){
        
        isPrivacy = true
        self.performSegueWithIdentifier("GoToPrivacy", sender: self)
        
    }
    
    
    func showTerms(){
        
        isPrivacy = false
        self.performSegueWithIdentifier("GoToTerms", sender: self)

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
        
        if let termsView = segue.destinationViewController as? TermsViewController {
            
                termsView.isPrivacy = isPrivacy
            
        }
    }
    
    
    //CountryPicker Delegate
    func didSelect(selection:[String:String]) {
        print("selection \(selection)")
        
        phoneField.becomeFirstResponder()
        
        self.countryCode.text = selection["dial_code"]
        self.code = selection["code"]!
        
        var code = selection["dial_code"]!
        var name = selection["name"]!
        
        self.selectCountryLabel.text = "\(name) (\(code))"
    
    }
}
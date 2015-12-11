//
//  LoginController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import UIKit
import AddressBook
import SwiftyJSON

class LoginController: BaseController, CountrySelectionPickerDelegate, UITextFieldDelegate {

    let msgTitle = Localizations.Contacts.Access.Request.Title
    let msgContent = Localizations.Contacts.Access.Request.Body
    
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
        let tap = UITapGestureRecognizer(target:self, action:"showCountryList")
        self.selectCountryLabel.addGestureRecognizer(tap)
        
        self.countrySelectionView.delegate = self;
        
        let policyTap = UITapGestureRecognizer(target:self, action:"showPolicy")
        self.privacyLink.addGestureRecognizer(policyTap)
        
        
        let termstap = UITapGestureRecognizer(target:self, action:"showTerms")
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

        if (phoneNumber.isEmpty) {
            showSimpleAlert(Localizations.Login.PhoneNumber.Required)
            showLoginButton()
            return;
        }
        // TODO: API strings
        let params: [String: AnyObject] = ["phone": phoneNumber, "country_code": code]
        API.sharedInstance.post("users", params: params, closure: { response in
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

    func textFieldDidBeginEditing(textField: UITextField) {
        if self.countrySelectionView.isCreated == true && self.countrySelectionView.hidden == false{
            self.countrySelectionView.doneAction()
        }
    }

    func askForAddressBookPermission() {
        let alert = UIAlertController(title: self.msgTitle, message: self.msgContent, preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: Localizations.General.Button.Notnow, style: UIAlertActionStyle.Cancel) {
            action in
            self.appDelegate.showContactsAccessView()
            })

        alert.addAction(UIAlertAction(title: Localizations.General.Button.Ok, style: UIAlertActionStyle.Default) {
            action in
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
            loggingPrint("requesting access...")
            let emptyDictionary = [:]
            let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(emptyDictionary, nil).takeRetainedValue()

            ABAddressBookRequestAccessWithCompletion(addressBook, {success, error in
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    if (success && error == nil) {
                        self.proceed()
                        return
                    }
                    self.appDelegate.contacts.isAuthorized()
                })
            })
        }
        else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            loggingPrint("access denied")
            self.appDelegate.contacts.isAuthorized()
        }
        else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            loggingPrint("access granted")
            self.proceed()
        }
    }

    func getCleanNumber(number: String? = nil) -> String {
        //TODO: sort this out and refactor
        guard let value: String = number ?? phoneField.text else {
            return ""
        }
        
        var characters = value.characters
        while characters.first == "0" {
            characters = characters.dropFirst()
        }
        return String(characters)
    }

    func getFormattedNumber() -> String {
        return self.countryCode.text! + self.getCleanNumber(self.phoneField.text)
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
        phoneField.becomeFirstResponder()
        
        self.countryCode.text = selection["dial_code"]
        self.code = selection["code"]!
        
        let code = selection["dial_code"]!
        let name = selection["name"]!
        self.selectCountryLabel.text = "\(name) (\(code))"
    }
}

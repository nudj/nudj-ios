//
//  LoginController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import SwiftyJSON

class LoginController: BaseController, SegueHandlerType, CountrySelectionPickerDelegate, UITextFieldDelegate {

    enum SegueIdentifier: String {
        case ShowVerifyView = "showVerifyView"
        case GoToPrivacy = "GoToPrivacy"
        case GoToTerms = "GoToTerms"
    }
    
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
    
    @IBAction func loginAct(sender: AnyObject) {
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
        API.sharedInstance.post("users", params: params, closure: { response in })
        
        self.performSegueWithIdentifier(.ShowVerifyView, sender: self)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.loginAct(textField)
        return true
    }

    func showPolicy(){
        isPrivacy = true
        self.performSegueWithIdentifier(.GoToPrivacy, sender: self)
    }
    
    func showTerms(){
        isPrivacy = false
        self.performSegueWithIdentifier(.GoToTerms, sender: self)
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

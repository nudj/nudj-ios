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

class LoginController: BaseController, SegueHandlerType, CountryPickerDelegate, UITextFieldDelegate {

    enum SegueIdentifier: String {
        case ShowVerifyView = "showVerifyView"
    }
    
    var iso2CountryCode = "GB"
    var textObserver: NSObjectProtocol?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var extendedPicker: NSLayoutConstraint!
    @IBOutlet weak var collapsedPicker: NSLayoutConstraint!

    override func viewDidLoad() {
        validateLogin()
        let nc = NSNotificationCenter.defaultCenter()
        textObserver = nc.addObserverForName(UITextFieldTextDidChangeNotification, object: phoneField, queue: nil) {
            notification in
            self.validateLogin()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowVerifyView:
            let verify = segue.destinationViewController as! VerifyViewController
            verify.phoneNumber = self.internationalPhoneNumber()
            verify.iso2CountryCode = self.iso2CountryCode
        }
    }
    
    func showCountryList(){
        self.phoneField.resignFirstResponder()
        // TODO: implement
    }
    
    @IBAction func login(sender: AnyObject) {
        let phoneNumber = internationalPhoneNumber()

        // TODO: API strings
        let params: [String: AnyObject] = ["phone": phoneNumber, "country_code": iso2CountryCode]
        API.sharedInstance.post("users", params: params, closure: { response in })
        
        self.performSegueWithIdentifier(.ShowVerifyView, sender: self)
    }
    
    func pickerIsExtended() -> Bool {
        return extendedPicker.priority > collapsedPicker.priority
    }
    
    func extendPicker() {
        UIView.animateWithDuration(0.5) {
            self.extendedPicker.priority = 750
            self.collapsedPicker.priority = 250
        }
    }
    
    func collapsePicker() {
        UIView.animateWithDuration(0.5) {
            self.extendedPicker.priority = 250
            self.collapsedPicker.priority = 750
        }
    }

    func validateLogin() {
        let number = formattedNumber()
        loginButton.enabled = !number.isEmpty
    }
    
    func internationalPhoneNumber() -> String {
        return (self.countryCode.text ?? "") + formattedNumber()
    }
    
    func formattedNumber() -> String {
        let number = phoneField.text ?? ""
        return shouldStripLeadingZeros() ? stripLeadingZeros(number) : number
    }
    
    func shouldStripLeadingZeros() -> Bool {
        return true // TODO: UK only
    }

    func stripLeadingZeros(number: String) -> String {
        var characters = number.characters
        while characters.first == "0" {
            characters = characters.dropFirst()
        }
        return String(characters)
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        validateLogin()
        if !loginButton.enabled {
            return false
        }
        self.login(textField)
        return true
    }
    
    // MARK: CountryPickerDelegate
    
    func didSelectData(data: CountryPickerDataSource.Data) {
        self.countryCode.text = "+" + data.diallingCode
        self.iso2CountryCode = data.iso2Code
        validateLogin()
    }
}

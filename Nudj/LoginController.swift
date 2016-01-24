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
    
    var iso2CountryCode = "GB" // default
    var shouldStripLeadingZeros: Bool = true // default
    var textObserver: NSObjectProtocol?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCode: UIButton!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var countyPickerContainer: UIView!
    @IBOutlet weak var countryPickerDataSource: CountryPickerDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start with the country picker hidden
        // doing this in IB conflicts with the height constraint, which we need
        countyPickerContainer.hidden = true 
        
        // try to apply the user's locale
        if let currentCountryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String,
            (row, data) = countryPickerDataSource.rowForIso2Code(currentCountryCode) {
            countryPicker.selectRow(row, inComponent: 0, animated: false)
            didSelectData(data)
        } else {
            // fall back to the defaults in IB
            validateLogin()
        }
        
        // listen to changes n the phone field
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
    
    @IBAction func login(sender: AnyObject) {
        let phoneNumber = internationalPhoneNumber()

        // TODO: API strings
        let params: [String: AnyObject] = ["phone": phoneNumber, "country_code": iso2CountryCode]
        API.sharedInstance.post("users", params: params, closure: { response in })
        
        performSegueWithIdentifier(.ShowVerifyView, sender: self)
    }
    
    @IBAction func toggleCountryPicker(sender: AnyObject) {
        let wasHidden = self.countyPickerContainer.hidden
        UIView.animateWithDuration(0.5) {
            self.countyPickerContainer.hidden = !wasHidden
        }
    }

    func validateLogin() {
        let number = formattedNumber()
        loginButton.enabled = !number.isEmpty
    }
    
    func internationalPhoneNumber() -> String {
        return (countryCode.currentTitle ?? "") + formattedNumber()
    }
    
    func formattedNumber() -> String {
        let number = phoneField.text ?? ""
        return shouldStripLeadingZeros ? stripLeadingZeros(number) : number
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
        countryCode.setTitle("+" + data.diallingCode, forState: .Normal)
        iso2CountryCode = data.iso2Code
        shouldStripLeadingZeros = data.shouldStripLeadingZeros
        validateLogin()
    }
}

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
    }
    
    var countrySelectionView = CountrySelectionPicker()
    var code = "GB"
    var textObserver: NSObjectProtocol?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCode: UITextField!

    override func viewDidLoad() {
        self.countrySelectionView.delegate = self
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
            verify.setValue(self.internationalPhoneNumber(), forKey: "phoneNumber")
            verify.code = self.code
        }
    }
    
    func showCountryList(){
        self.phoneField.resignFirstResponder()
        
        if self.countrySelectionView.isCreated == false{
            self.view.addSubview(self.countrySelectionView.createDropActionSheet(self.phoneField.frame.origin.y + self.phoneField.frame.size.height+5, width: view.frame.size.width))
        }
        self.countrySelectionView.showAction()
    }
    
    @IBAction func login(sender: AnyObject) {
        let phoneNumber = internationalPhoneNumber()

        // TODO: API strings
        let params: [String: AnyObject] = ["phone": phoneNumber, "country_code": code]
        API.sharedInstance.post("users", params: params, closure: { response in })
        
        self.performSegueWithIdentifier(.ShowVerifyView, sender: self)
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
        return true // TODO:
    }

    func stripLeadingZeros(number: String) -> String {
        var characters = number.characters
        while characters.first == "0" {
            characters = characters.dropFirst()
        }
        return String(characters)
    }

    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if self.countrySelectionView.isCreated == true && self.countrySelectionView.hidden == false{
            self.countrySelectionView.doneAction()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        validateLogin()
        if !loginButton.enabled {
            return false
        }
        self.login(textField)
        return true
    }
    
    // MARK: CountrySelectionPickerDelegate
    
    func didSelect(selection:[String:String]) {
        phoneField.becomeFirstResponder()
        
        self.countryCode.text = selection["dial_code"]
        self.code = selection["code"]!
    }
}

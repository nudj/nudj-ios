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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var selectCountryLabel: UILabel!

    override func viewDidLoad() {
        self.selectCountryLabel.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target:self, action:"showCountryList")
        self.selectCountryLabel.addGestureRecognizer(tap)
        
        self.countrySelectionView.delegate = self;
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

        switch segueIdentifierForSegue(segue) {
        case .ShowVerifyView:
            let verify = segue.destinationViewController as! VerifyViewController
            verify.setValue(self.getFormattedNumber(), forKey: "phoneNumber")
            verify.code = self.code
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

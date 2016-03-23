//
//  VerifyViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class VerifyViewController: BaseController, SegueHandlerType {
    
    enum SegueIdentifier: String {
        case UnwindToJobsList = "unwindToJobsList"
    }

    @IBOutlet weak var codeField: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.alpha = 0;
        }
    }

    @IBOutlet weak var smsText: UILabel!

    let codeLength = 4

    let phoneNumColor = UIColor(red: 0.09, green: 0.56, blue: 0.48, alpha: 1) // TODO: refactor
    var phoneNumber = ""
    var iso2CountryCode = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialSMSText = smsText.attributedText ?? NSAttributedString(string: smsText.text!, attributes: [NSFontAttributeName: smsText.font])

        let phoneNumText = NSMutableAttributedString(string: phoneNumber, attributes: [
            NSForegroundColorAttributeName: phoneNumColor,
            NSFontAttributeName: smsText.font

        ])

        let combinedText = NSMutableAttributedString(attributedString: initialSMSText)
        combinedText.appendAttributedString(phoneNumText)
        smsText.attributedText = combinedText
        smsText.sizeToFit()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        codeField.becomeFirstResponder()
        self.showCodeField(animated: true)
    }

    @IBAction func codeChanged(sender: UITextField) {
        if let field = sender as? VerifyCodeTextField {
            field.layout()
        }

        if (sender.text?.characters.count == codeLength) {
            codeField.resignFirstResponder()
            self.submit()
        }
    }

    @IBAction func resendButton() {
        // TODO: test this
        let path = API.Endpoints.Users.base
        let params = API.Endpoints.Users.paramsForResendVerification(phoneNumber)
        self.apiRequest(.POST, path: path, params: params, closure: {
            (json: JSON) in

            let verificationCode = json["data"]["code"].stringValue
            let verificationCodeMessage = Localizations.Verification.Code.Alert.Format(verificationCode)
            self.showSimpleAlert(verificationCodeMessage)
        })
    }

    func isValidResponse(json: JSON) -> Bool {
        return json["data"] != nil
            && json["data"]["id"] != nil
            && json["data"]["token"] != nil
        // TODO: check for completed
    }

    func submit() {
        guard let verificationCode: String = codeField.text else {
            return
        }
        codeField.text = ""

        if (verificationCode.characters.count != self.codeLength) {
            showSimpleAlert(Localizations.Verification.Code.Invalid)
            return
        }

        codeField.resignFirstResponder()
        hideCodeField()

        let path = API.Endpoints.Users.verify
        let params = API.Endpoints.Users.paramsForVerify(phoneNumber, iso2CountryCode: iso2CountryCode, verificationCode: verificationCode)
        self.apiRequest(API.Method.PUT, path: path, params: params, closure: {
            (json: JSON) in

            if (!self.isValidResponse(json)) {
                self.showCodeField(animated: true)
                self.showSimpleAlert(Localizations.Verification.Code.Invalid)
                return
            }

            // TODO: refactor the below out of the app delegate
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

            // TODO: API strings
            let user = appDelegate.user
            user.id = json["data"]["id"].intValue
            user.token = json["data"]["token"].stringValue
            user.completed = json["data"]["completed"].boolValue

            appDelegate.pushUserData()

            // Change user API token
            appDelegate.prepareApi()
            appDelegate.syncDeviceToken()

            // Connect to the chat server
            appDelegate.chatInst!.connect(user, inViewController: self)
            appDelegate.showLogin(self)
        }, errorHandler: {_ in
            self.showCodeField(animated: true)
            self.showSimpleAlert(Localizations.Verification.Code.Error)
        })
    }

    func hideCodeField() {
        self.activityIndicator.startAnimating()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.codeField.alpha = 0
            self.activityIndicator.alpha = 1
        })
    }

    func showCodeField(animated animated: Bool = true) {
        self.activityIndicator.stopAnimating()

        if (animated) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.codeField.alpha = 1
                self.activityIndicator.alpha = 0
            })
        } else {
            self.codeField.alpha = 1
            self.activityIndicator.alpha = 0
        }
    }

}

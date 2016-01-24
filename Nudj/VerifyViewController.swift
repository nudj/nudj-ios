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
        case ShowInitProfileView = "showInitProfileView"
        case UnwindToJobsList = "unwindToJobsList"
    }

    @IBOutlet weak var codeField: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.alpha = 0;
        }
    }

    @IBOutlet weak var smsText: UILabel!
    var initialSMSText: NSAttributedString? = nil

    let codeLength = 4

    var phoneNumber = ""
    var iso2CountryCode = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.initialSMSText == nil) {
            self.initialSMSText = NSAttributedString(string: smsText.text!, attributes: [
                NSFontAttributeName: smsText.font
            ])
        }

        let tmp = NSMutableAttributedString(string: phoneNumber, attributes: [
            NSForegroundColorAttributeName: UIColor(red: 0.09, green: 0.56, blue: 0.48, alpha: 1),
            NSFontAttributeName: smsText.font

        ])

        tmp.insertAttributedString(self.initialSMSText!, atIndex: 0)

        smsText.attributedText = tmp
        smsText.sizeToFit()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        codeField.becomeFirstResponder()
        self.showCodeField(animated: true)
    }

    @IBAction func CodeChanged(sender: UITextField) {
        if let field = sender as? VerifyCodeTextField {
            field.layout()
        }

        if (sender.text?.characters.count == codeLength) {
            self.submit()
        }
    }

    @IBAction func resendButton() {
        // TODO: API strings
        // TODO: test this
        self.apiRequest(.POST, path: "users", params: ["phone": phoneNumber], closure: {
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

        self.hideCodeField()

        // TODO: API strings
        self.apiRequest(API.Method.PUT, path: "users/verify", params: ["phone": phoneNumber, "verification": verificationCode, "country_code": iso2CountryCode], closure: {
            (json: JSON) in
            loggingPrint(json.stringValue)

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

            // Sync device token
            if (!appDelegate.deviceTokenSynced) {
                appDelegate.syncDeviceToken()
            }

            // Connect to the chat server
            appDelegate.chatInst!.connect(inViewController: self)
            appDelegate.showViewControllerWithIdentifier(.Main)
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

//
//  VerifyViewController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 27.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class VerifyViewController: BaseController {

    @IBOutlet weak var codeField: UITextField!

    @IBOutlet weak var smsText: UILabel!
    var initialSMSText: NSAttributedString? = nil

    var phoneNumber = ""
    var addressBookAccess = false

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
    }

    @IBAction func CodeChanged(sender: UITextField) {
        if (count(sender.text) == 5) {
            self.submit()
        }
    }

    @IBAction func resendButton() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

        self.apiRequest(.POST, path: "users", params: ["phone": phoneNumber], closure: {
            (json: JSON) in

            self.showSimpleAlert("Your new code is sent.")
        })
    }

    func isValidResponse(json: JSON) -> Bool {
        return json["data"] != nil
            && json["data"]["id"] != nil
            && json["data"]["token"] != nil
        // TODO: check for completed
    }

    func submit() {
        let code = codeField.text
        println("Sending Code: " + code)

        if (count(code) != 5) {
            showSimpleAlert("Invalid Code")
            return;
        }

        self.apiRequest(Method.PUT, path: "users/verify", params: ["phone": phoneNumber, "verification": code], closure: {
            (json: JSON) in
            NSLog(json.stringValue)

            if (!self.isValidResponse(json)) {

                if (json["error"] != nil) {
                    self.showSimpleAlert(json["error"]["message"].stringValue)
                } else {
                    self.showUnknownError()
                }

                return;
            }

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

            let user = appDelegate.user == nil ? UserModel() : appDelegate.user!
            user.id = Int32(json["data"]["id"].intValue)
            user.token = json["data"]["token"].stringValue
            user.completed = json["data"]["completed"].boolValue
            user.addressBookAccess = self.addressBookAccess

            appDelegate.pushUserData(user)

            // Sunc contacts
            Contacts().sync()
            
            self.performSegueWithIdentifier("showInitProfile", sender: nil)
        })
    }

}

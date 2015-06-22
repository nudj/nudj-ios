//
//  CompleteProfileController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 20.06.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class CompleteProfileController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.registerNotification()
        
        loadUserData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: User Management

    func loadUserData() {
        UserModel.getLocal(fillUserData)
        UserModel.getCurrent(["name"], closure: fillUserData)
    }

    func fillUserData(response:UserModel?) {
        if (response != nil) {
            fillUserData(response!)
        }
    }

    func fillUserData(response:UserModel) {
        
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    // MARK: TextViewDelegate

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        scrollToSuperView(textView)

        return true
    }

    func textViewDidChange(textView: UITextView) {
//        aboutMeIcon.highlighted = count(textView.text) > 0
    }

    // MARK: Scroll Management

    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)

        self.tableView?.contentInset = contentInsets
        self.tableView?.scrollIndicatorInsets = contentInsets
    }

    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        self.tableView?.contentInset = contentInsets
        self.tableView?.scrollIndicatorInsets = contentInsets
        self.tableView?.layoutIfNeeded()
    }

    func scrollToSuperView(view: UIView) {
        if (view.superview == nil) {
            return;
        }

        self.tableView?.setContentOffset(view.superview!.frame.origin, animated: true)
    }

    // MARK: Notifications Management

    func registerNotification() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

}

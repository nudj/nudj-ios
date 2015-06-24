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

    var defaultTopInset: CGFloat = 0.0

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

    func textFieldDidBeginEditing(textField: UITextField) {
        scrollToCell(textField)
    }

    // MARK: TextViewDelegate

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        scrollToCell(textView)

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

        if let table = self.tableView {
            var insets = table.contentInset
            insets.bottom = keyboardSize.height;
            defaultTopInset = insets.top

            table.contentInset = insets
            table.scrollIndicatorInsets = insets
        }

    }

    func keyboardWillBeHidden(sender: NSNotification) {
        if let table = self.tableView {
            var insets = table.contentInset
            insets.bottom = 0.0;

            table.contentInset = insets
            table.scrollIndicatorInsets = insets
            table.layoutIfNeeded()
        }

    }

    func scrollToCell(view: UIView) {
        if let table = self.tableView {
            if let cell = findContainingTableCell(view) {
                var point = cell.frame.origin
                point.y = point.y - defaultTopInset
                table.setContentOffset(point, animated: true)
            }
        }
    }

    func findContainingTableCell(view: UIView) -> UITableViewCell? {
        if let sView = view.superview {
            if let cell = sView as? UITableViewCell {
                return cell
            } else {
                return findContainingTableCell(sView)
            }
        }

        return nil
    }

    // MARK: Notifications Management

    func registerNotification() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

}

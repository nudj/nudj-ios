//
//  SendFeedBackViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class SendFeedBackViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var feedBackTextView: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.sendButton.enabled = !feedBackTextView.text.isEmpty
        self.feedBackTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.feedBackTextView.resignFirstResponder()
        self.tabBarController?.tabBar.hidden = false
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == feedBackTextView {
            self.sendButton.enabled = !feedBackTextView.text.isEmpty
        }
    }
    
    @IBAction func sendFeedBack(sender: UIBarButtonItem) {
        guard !self.feedBackTextView.text.isEmpty else {
            return
        }
        API.sharedInstance.request(.POST, path: "feedback", params: ["feedback":self.feedBackTextView.text], closure: { json in
            self.navigationController?.popViewControllerAnimated(true)
            }, errorHandler: { error in
                // TODO: error handling    
                loggingPrint(error)
        })
    }
}

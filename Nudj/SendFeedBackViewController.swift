//
//  SendFeedBackViewController.swift
//  Nudge
//
//  Created by Antonio on 29/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class SendFeedBackViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var feedBackTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.feedBackTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.feedBackTextView.resignFirstResponder()
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    func textViewDidChange(textView: UITextView) {
    }

    @IBAction func sendFeedBack(sender: UIBarButtonItem) {
        
        if(!self.feedBackTextView.text.isEmpty){
            API.sharedInstance.post("feedback", params: ["feedback":self.feedBackTextView.text], closure: { json in
                self.navigationController?.popViewControllerAnimated(true)
            }, errorHandler: { error in
                // TODO: eror handling    
                print(error)
            })
        } else {
            let alert:UIAlertView = UIAlertView(title: "No Text!", message: "Please add a comment", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }

}

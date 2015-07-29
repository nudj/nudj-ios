//
//  SendFeedBackViewController.swift
//  Nudge
//
//  Created by Antonio on 29/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class SendFeedBackViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = true
        self.textView.becomeFirstResponder()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.textView.resignFirstResponder()
        self.tabBarController?.tabBar.hidden = false
    }


}

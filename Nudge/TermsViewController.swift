//
//  TermsViewController.swift
//  Nudge
//
//  Created by Antonio on 29/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    var isPrivacy:Bool?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var url: NSURL?

        // Do any additional setup after loading the view.
        if(isPrivacy == true){
            url = NSURL(string: "http://api.nudj.co/html/privacy")
            self.title = "Privacy Policy"
        }else{
            url = NSURL(string: "http://api.nudj.co/html/terms")
            self.title = "Terms & Condition"
        }
        
        var requestObj:NSURLRequest  = NSURLRequest(URL: url!)
        self.webview.loadRequest(requestObj)
    }
    
    override func viewWillAppear(animated: Bool) {
     
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        
       self.tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

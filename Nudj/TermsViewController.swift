//
//  TermsViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    var isPrivacy:Bool?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var url: NSURL?

        // Do any additional setup after loading the view.
        // TODO: API strings
        if(isPrivacy == true){
            url = NSURL(string: "https://api.nudj.co/html/privacy")
            self.title = "Privacy Policy"
        }else{
            url = NSURL(string: "https://api.nudj.co/html/terms")
            self.title = "Terms & Condition"
        }
        
        let requestObj:NSURLRequest  = NSURLRequest(URL: url!)
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

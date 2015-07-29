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
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        var url = NSURL(string: "http://dev.juxtafeed.com/mobile/terms")
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

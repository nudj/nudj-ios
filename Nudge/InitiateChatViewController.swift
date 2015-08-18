//
//  InitiateChatViewController.swift
//  Nudge
//
//  Created by Antonio on 18/08/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class InitiateChatViewController: UIViewController, CreatePopupViewDelegate {

    @IBOutlet weak var textview: UITextView!
    
    var jobid:String?
    var userid:String?
    var username:String?
    var notificationid:String?
    
    var popup :CreatePopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Contact " + self.username!
        

    }

    
    override func viewWillAppear(animated: Bool) {
        
        self.textview.becomeFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendAction(sender: UIBarButtonItem) {
        
        if(!textview.text.isEmpty){
            var params = ["job_id":self.jobid!,"user_id":self.userid!,"notification_id":self.notificationid!,"message":textview.text]
            
            println("params ->\(params)")
            API.sharedInstance.put("nudge/chat", params:params, closure: { json in
                println("success \(json)")
                
                self.textview.resignFirstResponder()
                self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
                self.popup!.bodyText("You have successfully contacted \(self.username!)");
                self.popup?.delegate = self;
                self.view.addSubview(self.popup!)

            }, errorHandler: { error in
                println("error \(error)")
            })
         
        }
        
    }

    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(false, completion:nil)
       
    }
    
    func dismissPopUp() {
        popup!.removeFromSuperview();
        self.dismissViewControllerAnimated(false, completion:nil)

    }
    
    
}

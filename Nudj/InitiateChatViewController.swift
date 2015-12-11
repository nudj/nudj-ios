//
//  InitiateChatViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
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
        
        self.title = Localizations.Chat.Contact.Send.Format(self.username!)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.textview.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendAction(sender: UIBarButtonItem) {
        // TODO: AP{I strings
        if(!textview.text.isEmpty){
            let params = ["job_id":self.jobid!,"user_id":self.userid!,"notification_id":self.notificationid!,"message":textview.text]
            
            loggingPrint("params ->\(params)")
            API.sharedInstance.put("nudge/chat", params:params, closure: { json in
                loggingPrint("success \(json)")
                
                self.textview.resignFirstResponder()
                self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
                self.popup!.bodyText(Localizations.Chat.Contact.Success.Format(self.username!));
                self.popup?.delegate = self;
                self.view.addSubview(self.popup!)

            }, errorHandler: { error in
                loggingPrint("error \(error)")
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

//
//  InitiateChatViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class InitiateChatViewController: UIViewController, CreatePopupViewDelegate {

    @IBOutlet weak var textview: UITextView!
    
    var jobid: Int = 0
    var userid:  Int = 0
    var username: String = ""
    var notificationid: String = ""
    
    var popup :CreatePopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Localizations.Chat.Contact.Send.Format(self.username)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.textview.becomeFirstResponder()
    }
    
    @IBAction func sendAction(sender: UIBarButtonItem) {
        if(!textview.text.isEmpty){
            let path = API.Endpoints.Nudge.chat
            let params = API.Endpoints.Nudge.paramsForChat(jobid, userID: userid, notificationID: notificationid, message: textview.text)
            API.sharedInstance.request(.PUT, path: path, params: params, closure: { 
                json in
                
                self.textview.resignFirstResponder()
                let size = self.view.frame.size
                self.popup = CreatePopupView(x: 0, yCordinate: 0, width: size.width, height: size.height, imageName: "success", withText: true);
                self.popup!.bodyText(Localizations.Chat.Contact.Success.Format(self.username));
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

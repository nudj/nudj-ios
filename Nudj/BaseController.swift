//
//  BaseController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

private struct UnknownError : ErrorType {}

class BaseController: UIViewController {

    var chatCounter = 0;
    var notificationCounter = 0;
    
    override func viewDidLoad() {
         NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateBadge:", name: "updateBadgeValue", object: nil);
    }
    
    func showSimpleAlert(text: String) {
        // TODO: pass in an optional title
        let alert = UIAlertController(title: nil, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        let okButtonTitle = Localizations.General.Button.Ok
        alert.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func apiRequest(method: API.Method, path: String, params: [String: AnyObject]? = nil, closure: ((JSON) -> ())? = nil, errorHandler: (ErrorType -> Void)? = nil ) {
        // TODO: remove this singleton nastiness
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let token = API.sharedInstance.token ?? ""

        appDelegate.api!.request(method, path: path, params: params, closure: {
            (json: JSON) in

            if (json["status"].boolValue != true && json["data"] == nil) {
                loggingPrint(json)
                if (json["error"] != nil) {
                    self.showSimpleAlert(json["error"]["message"].stringValue)
                } else {
                    self.showSimpleAlert(Localizations.Server.Error.Unknown)
                }

                // TODO: sort this out - we have no error to pass here
                if (errorHandler != nil) {
                    errorHandler!(UnknownError())
                }

                return;
            }

            if (closure != nil) {
                closure!(json)
            }
        }, token: token, errorHandler: errorHandler)
    }

    func apiUpdateUser(params: [String: AnyObject], closure: ((JSON) -> ())?) {
        self.apiRequest(.PUT, path: "users", params: params, closure: closure)
    }
    
    func updateBadge(notification:NSNotification){
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        
        let index = Int(userInfo["index"]!)
        let badgeNumber = Int(userInfo["value"]!) ?? 0
        if(index == 1){
            self.chatCounter += badgeNumber
        }else{
            self.notificationCounter += badgeNumber
        }
        
        let tabArray = self.tabBarController?.tabBar.items as NSArray?
        if let tabArray = tabArray {
            if(tabArray.count > 0){
                let tabItem = tabArray.objectAtIndex(index!) as! UITabBarItem
                tabItem.badgeValue =  index == 1 ? "\(self.chatCounter)" : "\(self.notificationCounter)"
            }
        }
    }
}

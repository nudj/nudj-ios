//
//  BaseController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 27.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import UIKit

class BaseController: UIViewController {

    func showSimpleAlert(text: String) {
        self.showSimpleAlert(text, action: nil)
    }

    func showSimpleAlert(text: String, action: ((UIAlertAction) -> Void)?) {
        var alert = UIAlertController(title: nil, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) {
            alert in
            if (action != nil) {
                action!(alert)
            }
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func showUnknownError() {
        self.showSimpleAlert("Unknown Error Occured.")
    }

    func apiRequest(method: Method, path: String, params: [String: AnyObject]? = nil, closure: ((JSON) -> ())? = nil, errorHandler: ((NSError) -> Void)? = nil ) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;

        appDelegate.api?.request(method, path: path, params: params, closure: {
            (json: JSON) in
            NSLog(json.stringValue)

            if (json["status"].boolValue != true && json["data"] == nil) {
                if (json["error"] != nil) {
                    self.showSimpleAlert(json["error"]["message"].stringValue)
                } else {
                    self.showUnknownError()
                }
                if (closure != nil) {
                    closure!(nil)
                }
                return;
            }

            if (closure != nil) {
                closure!(json)
            }
        }, token: appDelegate.getUserToken(), errorHandler: errorHandler)
    }

    func apiUpdateUser(params: [String: AnyObject], closure: ((JSON) -> ())?) {
        self.apiRequest(.PUT, path: "users", params: params, closure: closure)
    }
}

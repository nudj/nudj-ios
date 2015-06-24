//
//  BaseController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 27.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

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

    func apiRequest(method: Alamofire.Method, path: String, params: [String: AnyObject]? = nil, closure: ((JSON) -> ())? = nil, errorHandler: ((NSError) -> Void)? = nil ) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let token = appDelegate.api!.token ?? ""

        appDelegate.api!.request(method, path: path, params: params, closure: {
            (json: JSON) in

            if (json["status"].boolValue != true && json["data"] == nil) {
                println(json)
                if (json["error"] != nil) {
                    self.showSimpleAlert(json["error"]["message"].stringValue)
                } else {
                    self.showUnknownError()
                }

                if (errorHandler != nil) {
                    errorHandler!(NSError())
                }

                return;
            }

            if (closure != nil) {
                closure!(json)
            }
        }, token: token, errorHandler: errorHandler)
    }

    func apiUpdateUser(params: [String: AnyObject], closure: ((JSON) -> ())?, errorHandler: ((NSError) -> Void)? = nil) {
        self.apiRequest(.PUT, path: "users", params: params, closure: closure, errorHandler: errorHandler)
    }
}

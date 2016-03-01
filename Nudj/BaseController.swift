//
//  BaseController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

private struct UnknownError : ErrorType {}

class BaseController: UIViewController {
    
    func showSimpleAlert(text: String) {
        // TODO: pass in an optional title
        let alert = UIAlertController(title: nil, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        let okButtonTitle = Localizations.General.Button.Ok
        alert.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func apiRequest(method: API.Method, path: String, params: [String: AnyObject]? = nil, closure: API.JSONHandler? = nil, errorHandler: API.ErrorHandler? = nil ) {
        // TODO: figure out when these alerts might fire and find a better UX for those cases
        let wrappedClosure: API.JSONHandler = {
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
                
                return
            }
            
            if (closure != nil) {
                closure!(json)
            }
        }
        
        // TODO: remove this singleton nastiness
        API.sharedInstance.request(method, path: path, params: params, closure: wrappedClosure, errorHandler: errorHandler)
    }
}

//
//  SocialHandlerModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import FBSDKLoginKit

// TODO: all this is horrible and needs to be cleaned up

class SocialHandlerModel: NSObject {

    func configureFacebook(connected:Bool,completionHandler:(success:Bool) -> Void){
        if(connected){
            self.deleteSocial("facebook", completionHandler: {
                result in
                completionHandler(success:result)
            })
        } else {
            // TODO: API strings
            let facebookReadPermissions = ["public_profile", "email", "user_friends", "user_about_me", "user_work_history", "user_location", "user_website"]
            let login = FBSDKLoginManager()
            login.logInWithReadPermissions(facebookReadPermissions, fromViewController: nil, handler:{ 
                (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if(error != nil){
                    loggingPrint("Facebook login error -> \(error)")
                    completionHandler(success:false)
                } else if result.isCancelled {
                    loggingPrint("Facebook login cancelled")
                    completionHandler(success:false)
                } else {
                    loggingPrint("Facebook access token -> \(result.token.tokenString)")
                    self.updateSocial("facebook", param: result.token.tokenString, completionHandler: { 
                        request in
                        completionHandler(success:request)
                    })
                }
            })
        }
    }

    func updateSocial(path:String, param:String, completionHandler:(success:Bool) -> Void){
        // TODO: API strings
        API.sharedInstance.put("connect/\(path)", params:["token":param], closure: { 
            json in
            loggingPrint("\(path) token stored successfully -> \(json)")
            completionHandler(success:true)
            }, 
            errorHandler: { 
                error in
                loggingPrint("error in storing \(path) token -> \(error)")
                completionHandler(success:false)
        })
        
    }
    
    func deleteSocial(path:String, completionHandler:(success:Bool) -> Void){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        API.sharedInstance.request(API.Method.DELETE, path: "connect/\(path)", params: nil, closure: { json in
            loggingPrint("\(path) token deleted successfully -> \(json)")
            completionHandler(success:true)
        }, token: appDelegate.user?.token, errorHandler: { 
            error in
            loggingPrint("error in deleting \(path) token -> \(error)")
            completionHandler(success:false)
        });
    }
}


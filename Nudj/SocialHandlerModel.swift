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
    typealias CompletionHandler = (Bool) -> Void

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
                    self.updateSocial("facebook", token: result.token.tokenString, completionHandler: { 
                        request in
                        completionHandler(success:request)
                    })
                }
            })
        }
    }

    func updateSocial(path: String, token: String, completionHandler: CompletionHandler) {
        let endpoint = API.Endpoints.Connect.byPath(path)
        let params = API.Endpoints.Connect.paramsForToken(token)
        API.sharedInstance.put(endpoint, params: params, closure: { 
            json in
            loggingPrint("\(path) token stored successfully -> \(json)")
            completionHandler(true)
            }, 
            errorHandler: { 
                error in
                loggingPrint("error in storing \(path) token -> \(error)")
                completionHandler(false)
        })
        
    }
    
    func deleteSocial(path: String, completionHandler: CompletionHandler) {
        let endpoint = API.Endpoints.Connect.byPath(path)
        API.sharedInstance.request(.DELETE, path: endpoint, params: nil, closure: { 
            json in
            loggingPrint("\(path) token deleted successfully -> \(json)")
            completionHandler(true)
        }, 
        errorHandler: { 
            error in
            loggingPrint("error in deleting \(path) token -> \(error)")
            completionHandler(false)
        });
    }
}

//
//  SocialHandlerModel.swift
//  Nudj
//
//  Created by Antonio on 31/07/2015.
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import FBSDKLoginKit


class SocialHandlerModel: NSObject {
   
    var reqClient:LIALinkedInHttpClient?
    var LinkedinPermission:String?
    
    init(viewController:UIViewController){
        
        super.init()
        // TODO: check that we mean LinkedIn here
        self.setLinkedInPermission(viewController)
        
    }
    
    func setLinkedInPermission(viewController:UIViewController){
        // TODO: check that we mean LinkedIn here
        API.sharedInstance.get("config/linkedin_permission", params: nil, closure: { response in
            
            loggingPrint(response["data"].stringValue)
            self.LinkedinPermission = response["data"].stringValue
            
            if self.LinkedinPermission!.isEmpty {
                self.LinkedinPermission = "r_basicprofile"
            }else{
                self.LinkedinPermission = response["data"].stringValue
            }
            
            self.reqClient = self.linkedInClientCongfig(viewController)

            
        }, errorHandler: {error in
                
            /* var alert = UIAlertView(title: "Server Error", message: "Oops, something went wrong. Could not get Linkedin's scope.", delegate: nil, cancelButtonTitle: "OK")
            alert.show() */
            
        })
        
     
    }
    
    //MARK: - Linked in config
    func configureLinkedin(connected:Bool,completionHandler:(success:Bool) -> Void){
        
        if(connected){
            
            self.deleteSocial("linkedin", completionHandler: { result in
                
                completionHandler(success:result)
                
            })
            
        }else{
            
            self.reqClient?.getAuthorizationCode({ code in
                self.reqClient?.getAccessToken(code, success: {accessTokenData in
                    
                    let accessToken = accessTokenData["access_token"] as! String
                    loggingPrint("Linkedin token -> \(accessToken)")
    
                    
                    self.updateSocial("linkedin", param: accessToken, completionHandler: { request in
                        
                        completionHandler(success:request)
                    })
                    
                    
                    }, failure: { error in
                        
                        completionHandler(success:false)
                        loggingPrint("Quering accessToken failed \(error)");
                })
                
                }, cancel: { cancel in
                    
                    completionHandler(success:false)
                    loggingPrint("Authorization was cancelled by user")
                    
                }, failure: { error in
                    
                    completionHandler(success:false)
                    loggingPrint("Authorization failed \(error)");
            })
            
        }
        
    }
    
    
    func requestMeWithToken(accessToken:String){
        
        self.reqClient?.GET("https://api.linkedin.com/v1/people/~?oauth2_access_token=\(accessToken)&format=json", parameters: nil, success: {result in
            loggingPrint("current user \(result)");
            }, failure: { error in
                loggingPrint("failed to fetch current user \(error)");
        })
        
    }
    
    func linkedInClientCongfig(viewController:UIViewController) -> LIALinkedInHttpClient{
        
        loggingPrint("configuring linkedin with \(self.LinkedinPermission!)")
        let application = LIALinkedInApplication.applicationWithRedirectURL("http://api.nudj.co", clientId:"77l67v0flc6leq", clientSecret:"PLOAmXuwsl1sSooc", state:"DCEEFWF45453sdffef424", grantedAccess:[self.LinkedinPermission!,"r_emailaddress"]) as! LIALinkedInApplication
        
        return LIALinkedInHttpClient(forApplication: application, presentingViewController: viewController)
    }

    
    //MARK: - FaceBook config
    func configureFacebook(connected:Bool,completionHandler:(success:Bool) -> Void){
        
        if(connected){
            
            self.deleteSocial("facebook", completionHandler: { result in
                
                completionHandler(success:result)
                
            })
            
        }else{
            let facebookReadPermissions = ["public_profile", "email", "user_friends", "user_about_me", "user_work_history", "user_location", "user_website"]
            let login = FBSDKLoginManager()
            login.logInWithReadPermissions(facebookReadPermissions, fromViewController: nil, handler:{ (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                
                if(error != nil){
                    loggingPrint("Facebook login error -> \(error)")
                    completionHandler(success:false)
                } else if result.isCancelled {
                    loggingPrint("Facebook login cancelled")
                    completionHandler(success:false)
                } else {
                    loggingPrint("Facebook access token -> \(result.token.tokenString)")
                    self.updateSocial("facebook", param: result.token.tokenString, completionHandler: { request in
                        completionHandler(success:request)
                    })
                }
            })
        }
    }
    
    
    //MARK: Updating social connection
    func updateSocial(path:String, param:String, completionHandler:(success:Bool) -> Void){
     
        API.sharedInstance.put("connect/\(path)", params:["token":param], closure: { json in
            
            loggingPrint("\(path) token stored successfully -> \(json)")
            completionHandler(success:true)
            
            }, errorHandler: { error in
                
            loggingPrint("error in storing \(path) token -> \(error)")
            completionHandler(success:false)
        })
        
    }
    
    func deleteSocial(path:String, completionHandler:(success:Bool) -> Void){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        API.sharedInstance.request(API.Method.DELETE, path: "connect/\(path)", params: nil, closure: { json in
            
            loggingPrint("\(path) token deleted successfully -> \(json)")
            completionHandler(success:true)

        }, token: appDelegate.user?.token, errorHandler: { error in
            
            loggingPrint("error in deleting \(path) token -> \(error)")
            completionHandler(success:false)
        
        });
        
    }

}


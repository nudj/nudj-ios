//
//  SocialHandlerModel.swift
//  Nudge
//
//  Created by Antonio on 31/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import FBSDKLoginKit


class SocialHandlerModel: NSObject {
   
    var reqClient:LIALinkedInHttpClient?

    init(viewController:UIViewController){
        
        super.init()
        self.reqClient = self.linkedInClientCongfig(viewController)
        
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
                    
                    var accessToken = accessTokenData["access_token"] as! String
                    println("Linkedin token -> \(accessToken)")
    
                    
                    self.updateSocial("linkedin", param: accessToken, completionHandler: { request in
                        
                        completionHandler(success:request)
                    })
                    
                    
                    }, failure: { error in
                        
                        completionHandler(success:false)
                        println("Quering accessToken failed \(error)");
                })
                
                }, cancel: { cancel in
                    
                    completionHandler(success:false)
                    println("Authorization was cancelled by user")
                    
                }, failure: { error in
                    
                    completionHandler(success:false)
                    println("Authorization failed \(error)");
            })
            
        }
        
    }
    
    
    func requestMeWithToken(accessToken:String){
        
        self.reqClient?.GET("https://api.linkedin.com/v1/people/~?oauth2_access_token=\(accessToken)&format=json", parameters: nil, success: {result in
            println("current user \(result)");
            }, failure: { error in
                println("failed to fetch current user \(error)");
        })
        
    }
    
    func linkedInClientCongfig(viewController:UIViewController) -> LIALinkedInHttpClient{
        
        var application = LIALinkedInApplication.applicationWithRedirectURL("http://api.nudj.co", clientId:"77l67v0flc6leq", clientSecret:"PLOAmXuwsl1sSooc", state:"DCEEFWF45453sdffef424", grantedAccess:["r_basicprofile","r_emailaddress"]) as! LIALinkedInApplication
        
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
            login.logInWithReadPermissions(facebookReadPermissions, handler:{ (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                
                if(error != nil){
                    
                    println("Facebook login error -> \(error)")
                    completionHandler(success:false)
                    
                } else if result.isCancelled {
                    
                    println("Facebook login cancelled")
                    completionHandler(success:false)
                    
                    
                } else {
                    
                    println("Facebook access token -> \(result.token.tokenString)")
                    
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
            
            println("\(path) token stored successfully -> \(json)")
            completionHandler(success:true)
            
            }, errorHandler: { error in
                
            println("error in storing \(path) token -> \(error)")
            completionHandler(success:false)
        })
        
    }
    
    func deleteSocial(path:String, completionHandler:(success:Bool) -> Void){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        API.sharedInstance.request(Alamofire.Method.DELETE, path: "connect/\(path)", params: nil, closure: { json in
            
            println("\(path) token deleted successfully -> \(json)")
            completionHandler(success:true)

        }, token: appDelegate.user?.token, errorHandler: { error in
            
            println("error in deleting \(path) token -> \(error)")
            completionHandler(success:false)
        
        });
        
    }

}


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

class SocialHandlerModel: NSObject {
   
    var reqClient:LIALinkedInHttpClient?

    override init(){
        
        self.reqClient = LIALinkedInHttpClient()
    }
    
    //MARK: - Linked in config
    func configureLinkedin(connected:Bool,completionHandler:(success:Bool) -> Void){
        
    }
    
    //MARK: - FaceBook config
    func configureFacebook(connected:Bool,completionHandler:(success:Bool) -> Void){
        
        if(connected == true){
            
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


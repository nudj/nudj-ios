//
//  API.swift
//  Nudge
//
//  Created by Lachezar Todorov on 26.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class API {

    // Server4u
    var baseURL = "http://api.nudj.co/api/v1/"

    static let sharedInstance = API();


    // Standard Call without specitying token
    func request(method: Alamofire.Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? ) {
        self.request(method, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    func request(method: Alamofire.Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), token: String?, errorHandler: ((NSError) -> Void)? ) {
        let manager = Manager.sharedInstance

        if (token != nil) {
            manager.session.configuration.HTTPAdditionalHeaders = ["token": token!]
            println("Token: " + token!)
        }
        
        manager.request(method, baseURL + path, parameters: params, encoding: .JSON).responseString {
            (request, rawResponse, response, error) in

            println("Request: \(request)")

            // We have API Error
            if (rawResponse != nil && rawResponse!.statusCode >= 400) {

                println("[API.request] rawResponse: \(rawResponse!)")

                // Try to get error code
                if (response != nil) {
                    println("[API.request] Response: \(response!)")
                    if let errorFromString = response!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {

                        let errorJson = JSON(data: errorFromString)

                        // Log out user and show Login screen
                        if (errorJson["error"]["error_code"] == 10002) { // Unauthorized
                            println("Logout!")
                            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            delegate.logout()
                            delegate.pushViewControllerWithId("loginController")
                            return
                        }
                    }
                }
            }

            if (error != nil) {

                if (rawResponse != nil) {
                    println("Response Details: \(rawResponse!.statusCode) \(rawResponse!.description)")
                    println("Response: \(response!)")
                }

                println("[API.request] Error: \(error!)")

                if(errorHandler != nil) {
                    errorHandler!(error!)
                }

                return

            } else if (response == nil) {

                if(errorHandler != nil) {
                    errorHandler!(NSError())
                }
                return

            }

            if let dataFromString = response!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {

                closure(JSON(data: dataFromString))

            } else if(errorHandler != nil) {
                errorHandler!(error!)
            }
        }
    }
    
}
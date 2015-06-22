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

    // Production
    var baseURL = "http://api.nudj.co/api/v1/"
    var token:String? = nil

    // Server4u
    // var baseURL = "http://95.87.227.252:8080/nudge/public/index.php/api/v1/"

    static var sharedInstance = API();


    // Standard Call without specitying token
    func request(method: Alamofire.Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? ) {
        self.request(method, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    // MARK: Standard Requests Without token
    func get(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? ) {
        self.request(Method.GET, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    func post(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? ) {
        self.request(Method.POST, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    func put(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? ) {
        self.request(Method.PUT, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    // MARK: General request

    func request(method: Alamofire.Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), token: String?, errorHandler: ((NSError) -> Void)? ) {
        let manager = Manager.sharedInstance
        manager.session.configuration.HTTPShouldSetCookies = false
        manager.session.configuration.HTTPMaximumConnectionsPerHost = 8

        if (token != nil) {
            manager.session.configuration.HTTPAdditionalHeaders = ["token": token!]
        } else if self.token != nil {
            manager.session.configuration.HTTPAdditionalHeaders = ["token": self.token!]
        }
        
        manager.request(method, (baseURL + path) as String, parameters: params).responseString { // , encoding: .JSON //Removed this ... no Idea why it works without it and some times it does not with it.
            (request, rawResponse, response, error) in

            // Try to catch general API errors
            if (self.tryToCatchAPIError(rawResponse, response: response)) {
                // We have general error from server and the user should not continue.
                return
            }

            if (error != nil) {

                if (rawResponse != nil) {
                    println("Response Details: \(rawResponse!.statusCode) \(rawResponse!.description)")
                    println("Response: \(response!)")
                }

                println("[API.request] Error: \(error!)")

                errorHandler?(NSError())

                return

            } else if (response == nil) {

                errorHandler?(NSError())

                return
            }

            if let dataFromString = response!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {

                let json = JSON(data: dataFromString)

                if (json.null != nil) {
                    errorHandler?(NSError())
                } else {
                    closure(json)
                }

            } else if(errorHandler != nil) {

                errorHandler!(NSError())

            }
        }
    }

    func tryToCatchAPIError(rawResponse: NSHTTPURLResponse?, response: String?) -> Bool {

        if (rawResponse != nil && rawResponse!.statusCode >= 400) {

            println("[API Error] rawResponse: \(rawResponse!)")

            // Try to get error code
            if (response != nil) {
                println("[API Error] Response: \(response!)")
                if let errorFromString = response!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {

                    let errorJson = JSON(data: errorFromString)

                    let code = errorJson["error"]["error_code"];

                    // Log out user and show Login screen
                    if (code == 10002) {
                        println("Unauthorized -> Logout!")
                        self.performLogout()
                        return true
                    } else if (code == 10004) {
                        println("Invalid Token -> Logout!")
                        self.performLogout()
                        return true
                    }
                }
            }
        }

        return false
    }

    func performLogout() {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.logout()
        delegate.pushViewControllerWithId("loginController")
    }

}
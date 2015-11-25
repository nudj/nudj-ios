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

    // TODO: remove this singleton (NB it isn't even implemented correctly)
    static var sharedInstance = API();


    // Standard Call without specitying token
    func request(method: Alamofire.Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? ) {
        self.request(method, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    // MARK: Standard Requests Without token
    func get(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? = nil) {
        self.request(Method.GET, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    func post(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? = nil) {
        self.request(Method.POST, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    func put(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? = nil) {
        self.request(Method.PUT, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    // MARK: General request

    func request(method: Alamofire.Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), token: String?, errorHandler: ((NSError) -> Void)? ) {
        let manager = Manager.sharedInstance
        manager.session.configuration.HTTPShouldSetCookies = false
        manager.session.configuration.HTTPMaximumConnectionsPerHost = 8

        var headers = ["Content-Type":"application/json"]
        
        if (token != nil) {
            //manager.session.configuration.HTTPAdditionalHeaders = ["token": token!]
            
            //IOS 9 Work around
             headers = [
                "token": token!,
            ]
            
        } else if self.token != nil {
            //manager.session.configuration.HTTPAdditionalHeaders = ["token": self.token!]
            
            //IOS 9 Work around
            headers = [
                "token": self.token!,
            ]
            
        }

        
       let encoding = method != Alamofire.Method.GET ? Alamofire.ParameterEncoding.JSON : Alamofire.ParameterEncoding.URL
        
        Alamofire.request(method, (baseURL + path) as String, parameters: params, encoding: encoding, headers: headers).responseString {
        //manager.request(method, (baseURL + path) as String, parameters: params, encoding: encoding).responseString {
            (request, rawResponse, response, error) in
            
            // Try to catch general API errors
            if (self.tryToCatchAPIError(rawResponse, response: response)) {
                // We have general error from server and the user should not continue.
                return
            }

            if (error != nil) {

                if (rawResponse != nil) {
                    print("Response Details: \(rawResponse!.statusCode) \(rawResponse!.description)")
                    print("Response: \(response!)")
                }

                print("[API.request] Error: \(error!)")

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

            } else {

                errorHandler?(NSError())

            }
        }
    }

    func tryToCatchAPIError(rawResponse: NSHTTPURLResponse?, response: String?) -> Bool {

        if (rawResponse != nil && rawResponse!.statusCode >= 400) {

            // Try to get error code
            if (response != nil) {
                print("[API Error] Response: \(response!)")
                if let errorFromString = response!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {

                    let errorJson = JSON(data: errorFromString)

                    let code = errorJson["error"]["code"];

                    // Log out user and show Login screen
                    if (code == 10401) {
                        print("Unauthorized -> Logout!")
                        self.performLogout()
                        return true
                    } else if (code == 11101) {
                        print("Invalid Token -> Logout!")
                        self.performLogout()
                        return true
                    }
                }
            } else {
                print("[API Error] rawResponse: \(rawResponse!)")
            }
        }

        return false
    }

    func performLogout() {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.logout()
        delegate.changeRootViewController("loginController")
    }

}
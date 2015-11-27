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
    typealias Method = Alamofire.Method

    // Production
    // TODO: API strings
    let baseURL = "http://api.nudj.co/api/v1/"
    var token:String? = nil

    // TODO: remove this singleton (NB it isn't even implemented correctly)
    static var sharedInstance = API();

    // Standard Call without specifying token
    func request(method: Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((ErrorType) -> Void)? ) {
        self.request(method, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    // MARK: Standard Requests Without token
    func get(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((ErrorType) -> Void)? = nil) {
        self.request(Method.GET, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    func post(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((ErrorType) -> Void)? = nil) {
        self.request(Method.POST, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    func put(path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((ErrorType) -> Void)? = nil) {
        self.request(Method.PUT, path: path, params: params, closure: closure, token: nil, errorHandler: errorHandler)
    }

    // MARK: General request

    func request(method: Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), token: String?, errorHandler: ((ErrorType) -> Void)? ) {
        let manager = Manager.sharedInstance
        manager.session.configuration.HTTPShouldSetCookies = false
        manager.session.configuration.HTTPMaximumConnectionsPerHost = 8

        var headers = ["Content-Type":"application/json"]
        // TODO: investigate this workaround
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
        
       let encoding = (method != Method.GET) ? Alamofire.ParameterEncoding.JSON : Alamofire.ParameterEncoding.URL
        
        Alamofire.request(method, (baseURL + path) as String, parameters: params, encoding: encoding, headers: headers).responseJSON {
            (request, response, result) in
            // Try to catch general API errors
            if (self.tryToCatchAPIError(response, result: result)) {
                // We have general error from server and the user should not continue.
                return
            }

            switch result {
            case .Success(let value):
                let json = JSON(value)
                closure(json)
                break
                
            case .Failure(_, let error):
                errorHandler?(error)
                break
            }
        }
    }

    func tryToCatchAPIError(rawResponse: NSHTTPURLResponse?, result: Result<AnyObject>) -> Bool {
        guard let rawResponse = rawResponse else {
            return false
        }
        guard rawResponse.statusCode >= 400 else {
            return false
        }
        
        switch result {
        case .Success(let value):
            // Try to get error code from the JSON
            let errorJson = JSON(value)
            let code = errorJson["error"]["code"];
            
            // Log out user and show Login screen
            if (code == 10401) {
                loggingPrint("Unauthorized -> Logout!")
                self.performLogout()
                return true
            } else if (code == 11101) {
                loggingPrint("Invalid Token -> Logout!")
                self.performLogout()
            }
            break
            
        case .Failure(_, let error):
            // TODO: improve error handling here
            loggingPrint("[API Error] rawResponse: \(rawResponse) Error: \(error)")
            break
        }

        return true
    }

    func performLogout() {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.logout()
        delegate.changeRootViewController("loginController")
    }

}

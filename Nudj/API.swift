//
//  API.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class API {
    typealias Method = Alamofire.Method
    typealias JSONHandler = (JSON) -> Void
    typealias ErrorHandler = (ErrorType) -> Void
    
    struct APIError: ErrorType, CustomDebugStringConvertible {
        let code :Int
        let message :String
        
        var debugDescription: String { 
            return "code: \(code), message: \(message)" 
        }
    }
    
    // Production
    // TODO: API strings
    var baseURL: String { return server.URLString + "api/v1/" }
    var token: String? = nil
    
    var manager: Alamofire.Manager = {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPShouldSetCookies = false
        return Manager(configuration: configuration)
    }()

    // TODO: remove this singleton
    static var sharedInstance = API()

    // MARK: Standard Requests Without token
    func get(path: String, params: [String: AnyObject]? = nil, closure: JSONHandler, errorHandler: ErrorHandler? = nil) {
        self.request(.GET, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }

    func post(path: String, params: [String: AnyObject]? = nil, closure: JSONHandler, errorHandler: ErrorHandler? = nil) {
        self.request(.POST, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }

    func put(path: String, params: [String: AnyObject]? = nil, closure: JSONHandler, errorHandler: ErrorHandler? = nil) {
        self.request(.PUT, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }

    // MARK: General request
    func request(method: Method, path: String, params: [String: AnyObject]? = nil, closure: JSONHandler, errorHandler: ErrorHandler? ) {
        var headers = ["Content-Type": "application/json"]
        if let token = self.token {
            headers["token"] = token
        }
        
        let encoding = (method != .GET) ? Alamofire.ParameterEncoding.JSON : Alamofire.ParameterEncoding.URL
        manager.request(method, (baseURL + path) as String, parameters: params, encoding: encoding, headers: headers).responseJSON {
            response in
            // Try to catch general API errors
            if (self.tryToCatchAPIError(response, errorHandler: errorHandler)) {
                // We have general error from server and the user should not continue.
                return
            }
            
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                closure(json)
                break
                
            case .Failure(let error):
                errorHandler?(error)
                break
            }
        }
    }

    func tryToCatchAPIError(response: Alamofire.Response<AnyObject, NSError>, errorHandler: ErrorHandler?) -> Bool {
        guard let rawResponse: NSHTTPURLResponse = response.response else {
            return false
        }
        guard rawResponse.statusCode >= 400 else {
            return false
        }
        
        switch response.result {
        case .Success(let value):
            // Try to get error code from the JSON
            let errorJson = JSON(value)
            let code = errorJson["error"]["code"].numberValue.intValue
            let message = errorJson["error"]["message"].stringValue
            
            // Log out user and show Login screen
            if (code == 10401) {
                loggingPrint("Unauthorized -> Logout!")
                self.performLogout()
            } else if (code == 11101) {
                loggingPrint("Invalid Token -> Logout!")
                self.performLogout()
            } else {
                loggingPrint("API error: \(message)")
            }
            errorHandler?(APIError(code: Int(code), message: message))
            break
            
        case .Failure(let error):
            // TODO: improve error handling here
            loggingPrint("[API Error] rawResponse: \(rawResponse) Error: \(error)")
            errorHandler?(error)
            break
        }

        return true
    }

    func performLogout() {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.deleteAllData()
        delegate.showViewControllerWithIdentifier(.Login)
    }
}

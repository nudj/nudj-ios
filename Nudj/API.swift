//
//  API.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import SwiftyJSON

final class API {
    // From https://tools.ietf.org/html/rfc7231#section-4.3
    enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }
    
    enum ParameterEncoding {
        case URL, JSON
        
        func encode(params: [String: AnyObject], ontoRequest request: NSMutableURLRequest) {
            switch self {
            case URL:
                var paramString = ""
                let characterSet = NSCharacterSet.URLQueryAllowedCharacterSet()
                for (key, value) in params {
                    let escapedKey = String(key).stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
                    let escapedValue = String(value).stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
                    paramString += "\(escapedKey)=\(escapedValue)&"
                }
                
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
                
            case JSON:
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.HTTPBody = data
                } catch {
                    fatalError("Error \(error) JSON encoding parameters \(params)")
                }
            }
        }
    }
    
    typealias JSONHandler = (JSON) -> Void
    typealias ErrorHandler = (ErrorType) -> Void
    
    struct APIError: ErrorType, CustomDebugStringConvertible {
        let code :Int
        let message :String
        
        var debugDescription: String { 
            return "code: \(code), message: \(message)" 
        }
    }
    
    var baseURL: String { return server.URLString + Endpoints.versionPath }
    var token: String? = nil
    let session: NSURLSession
    
    init() {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPShouldSetCookies = false
        session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    deinit {
        session.invalidateAndCancel()
    }

    // TODO: remove this singleton
    static var sharedInstance = API()

    // MARK: Convenience request methods
    func get(path: String, params: [String: AnyObject]? = nil, closure: JSONHandler? = nil, errorHandler: ErrorHandler? = nil) {
        self.request(.GET, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }

    func post(path: String, params: [String: AnyObject]? = nil, closure: JSONHandler? = nil, errorHandler: ErrorHandler? = nil) {
        self.request(.POST, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }

    func put(path: String, params: [String: AnyObject]? = nil, closure: JSONHandler? = nil, errorHandler: ErrorHandler? = nil) {
        self.request(.PUT, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }

    func delete(path: String, params: [String: AnyObject]? = nil, closure: JSONHandler? = nil, errorHandler: ErrorHandler? = nil) {
        self.request(.DELETE, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }
    
    // MARK: General request
    func request(method: Method, path: String, params: [String: AnyObject]? = nil, closure: JSONHandler? = nil, errorHandler: ErrorHandler? = nil ) {
        let request = clientURLRequest(method, path: path, params: params)
        let task = dataTask(request, method: method, closure: closure, errorHandler: errorHandler)
        task.resume()
    }

    private func dataTask(request: NSMutableURLRequest, method: Method, closure: JSONHandler? = nil, errorHandler: ErrorHandler? = nil) -> NSURLSessionDataTask {
        let dataTask = session.dataTaskWithRequest(request) { 
            (data, response, error) -> Void in
            if let data = data, response = response {
                self.handleResponse(response, data: data, closure: closure, errorHandler: errorHandler)
            } else if let error = error {
                errorHandler?(error)
            }
        }
        return dataTask
    }
    
    private func clientURLRequest(method: Method, path: String, params: [String: AnyObject]? = nil) -> NSMutableURLRequest {
        // TEMP DEBUG
        if path.containsString("?") {
            loggingPrint( "Suspicious path component \"\(path)\"")
        }
        
        let characterSet = NSCharacterSet.URLPathAllowedCharacterSet()
        let encodedPath = path.stringByAddingPercentEncodingWithAllowedCharacters(characterSet) ?? ""
        guard let url = NSURL(string: self.baseURL + encodedPath) else {
            fatalError("Cannot form URL from \(encodedPath)")
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        
        let encoding: ParameterEncoding = (method == .GET) ? .URL : .JSON
        if let params = params {
            encoding.encode(params, ontoRequest: request)
        }
        
        if let token = self.token {
            request.addValue(token, forHTTPHeaderField: "token")
        }
        
        return request
    }
    
    private func handleResponse(response: NSURLResponse, data: NSData, closure: JSONHandler? = nil, errorHandler: ErrorHandler? = nil) {
        guard let response = response as? NSHTTPURLResponse else {
            fatalError("The NSURLSessionDataTask API promises an NSHTTPURLResponse")
        }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            let statusCode = response.statusCode
            switch statusCode {
            case 200...299:
                let swiftyJson = JSON(json)
                closure?(swiftyJson)
                
            default:
                if statusCode >= 400 {
                    self.handleAPIError(json, errorHandler: errorHandler)
                } else {
                    errorHandler?(APIError(code: statusCode, message: "Unexpected API error \(statusCode)"))
                }
            }
        } catch {
            errorHandler?(error)
        }
    }
    
    private func handleAPIError(value: AnyObject, errorHandler: ErrorHandler?) {
        // Try to get error code from the JSON
        let errorJson = JSON(value)
        let code = errorJson["error"]["code"].numberValue.intValue
        let message = errorJson["error"]["message"].stringValue
        
        // TODO: API strings and constants
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
    }

    private func performLogout() {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.deleteAllData()
        delegate.showViewControllerWithIdentifier(.Login)
    }
}

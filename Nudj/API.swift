//
//  API.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import SwiftyJSON

final class API {
    /// HTTP methods as per https://tools.ietf.org/html/rfc7231#section-4.3
    enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
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
    
    var token: String? = nil
    
    init() {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPShouldSetCookies = false
        session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        session.sessionDescription = "Nudj API session"
    }
    
    deinit {
        session.invalidateAndCancel()
    }

    // TODO: remove this singleton
    static var sharedInstance = API()

    /// Initiate an API request
    ///
    /// - parameter method: The HTTP method (GET, PUT, etc) to use.
    ///
    /// - parameter path: The path component of the URL. This will be percent-encoded as a path component.  
    /// **Warning**: do not append query parameters here: they will be percent-encoded into the path, which is not what you want. This is to allow user-generated components, such as search terms, to be sent in the path component even if they contain "query-like" characters such as '?', '=', and '&'.
    ///
    /// - parameter params: A dictionary of query parameters. This will be either JSON encoded or URL encoded with percent-encoding, whichever is appropriate for the HTTP method.
    ///
    /// - parameter closure: A closure that receives the result upon success.
    ///
    /// - parameter errorHandler: A closure that receives the error object upon failure.
    ///
    func request(method: Method, path: String, params: [String: AnyObject]? = nil, closure: JSONHandler? = nil, errorHandler: ErrorHandler? = nil ) {
        let request = clientURLRequest(method, path: path, params: params)
        let task = dataTask(request, method: method, closure: closure, errorHandler: errorHandler)
        task.resume()
    }

    // MARK: Implementation
    
    private var baseURL: String { return server.URLString + Endpoints.versionPath }
    
    private let session: NSURLSession
    
    private enum ParameterEncoding {
        case URL, JSON
        
        func encode(params: [String: AnyObject], ontoRequest request: NSMutableURLRequest) {
            switch self {
            case URL:
                guard let components = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: true) else {return}
                let queryItems = params.map {
                    key, value in 
                    return NSURLQueryItem(name: key, value: String(value))
                }
                components.queryItems = queryItems
                request.URL = components.URL
                
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
        
        let encoding: ParameterEncoding
        switch method {
        case .GET, .HEAD, .DELETE:
            encoding = .URL
            
        default:
            encoding = .JSON
        }
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
        delegate.showLogin(self)
    }
}

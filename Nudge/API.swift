//
//  API.swift
//  Nudge
//
//  Created by Lachezar Todorov on 26.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation

class API {

//    var baseURL = "http://192.168.3.139/eman/nudge-api/project/public/api/v1/"
    var baseURL = "http://95.87.227.252:8080/nudge/public/index.php/api/v1/"

    func request(method: Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? ) {
        self.request(method, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }

    func request(method: Method, path: String, params: [String: AnyObject]? = nil, closure: (JSON) -> (), token: String?, errorHandler: ((NSError) -> Void)? ) {
        let manager = Manager.sharedInstance

        if (token != nil) {
            manager.session.configuration.HTTPAdditionalHeaders = ["token": token!]
            println("Token: " + token!)
        }
        
        manager.request(method, baseURL + path, parameters: params, encoding: .JSON)
            .responseJSON{ (request, rawResponse, JSONResponse, error) in
                println(request)

                if (error != nil) {
                    println(rawResponse)
                    println(error)
                } else {
//                    println(JSONResponse)
                }

                if (JSONResponse != nil) {
                    closure(JSON(JSONResponse!))
                } else if(errorHandler != nil) {
                    errorHandler!(error!)
                }
        }
    }

    
}
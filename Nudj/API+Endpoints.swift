//
//  API+Endpoints.swift
//  Nudj
//
//  Created by Richard Buckle on 15/02/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

extension API {
    struct Endpoints {
        struct Jobs {
            static let available = "jobs/available"
            
            static func search(searchTerm: String?) -> String {
                guard let searchTerm = searchTerm else {
                    return available
                }
                return "jobs/search/\(searchTerm)"
            }
            
            static func paramsForList(page: Int, pageSize: Int) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "params": "job.title,job.salary,job.bonus,job.user,job.location,job.company,user.name,user.image",
                    "sizes": "user.profile",
                    "page": page,
                    "limit": pageSize
                ]
                return params
            }
        }
        
        struct Users {
            static let me = "users/me"
            
            static func byID(userID: Int?) -> String {
                guard let userID = userID else {
                    return me
                }
                guard userID > 0 else {
                    return me
                }
                return "users/\(userID)"
            }
            
            static func favouriteByID(userID: Int?) -> String {
                let userPath = byID(userID) 
                return userPath + "/favourite"
            }
            
            static func paramsForFields(fields: [String]) -> [String: String] {
                let userFields = fields.reduce("", combine: {$0! + "," + $1}) ?? ""
                return ["params": userFields]
            }
        }
        
        struct PlaceHolders {
            static let defaultUserImage = "app/placeholder/user.png"
        }
    }
}

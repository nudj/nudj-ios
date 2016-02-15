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
    }
}

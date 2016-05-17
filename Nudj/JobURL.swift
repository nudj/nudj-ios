//
//  JobURL.swift
//  Nudj
//
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

enum JobURL {
    case Main(Int), Preview(Int)
    
    func path() -> String {
        switch self {
        case .Main(let jobID):
            return "/job/\(jobID)"
        case .Preview(let jobID):
            return "/jobpreview/\(jobID)"
        }
    }
    
    func url() -> NSURL {
        let api = API()
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = api.server.mobileWebHostname
        components.path = self.path()
        let url = components.URL!
        return url
    }
}

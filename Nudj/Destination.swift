//
//  Destination.swift
//  Nudj
//
//  Created by Richard Buckle on 22/03/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

public enum Destination: Equatable {
    case None
    case Job(Int)
    
    public init(url: NSURL) {
        self = Destination.fromURL(url)
    }
    
    static func fromURL(url: NSURL) -> Destination {
        switch url.scheme {
        case "http", "https":
            break
            
        default:
            return .None
        }
        
        guard let host = url.host else {
            return .None
        }
        switch host {
            case "mobileweb.nudj.co":
            break
            
        default:
            return .None
        }
        
        guard let pathComponents = url.pathComponents else {
            return .None
        }
        if pathComponents.count < 3 {
            return .None
        }
        
        let pathPrefix = pathComponents[1]
        switch pathPrefix {
        case "jobpreview":
            let jobIDStr = pathComponents[2]
            if let jobID = Int(jobIDStr) {
                return .Job(jobID)
            }
            return .None
            
        default:
            return .None
        }
    }
}

public func == (lhs: Destination, rhs: Destination) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None):
        return true
        
    case (.Job(let lhsID), .Job(let rhsID)):
        return lhsID == rhsID

    default: 
        return false
    }
}

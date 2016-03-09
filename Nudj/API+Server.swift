//
//  API+Server.swift
//  Nudj
//
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

protocol URLStringConvertible {
    var URLString: String { get }
}

extension API {
    enum Server: String, URLStringConvertible, CustomStringConvertible {
        case Production, Development
        
        var URLString: String {
            switch self {
            case Production:
                return "https://api.nudj.co/"
            case Development:
                return "https://dev.nudj.co/"
            }
        }
        
        var chatHostname: String {
            switch self {
            case Production:
                return "chat.nudj.co"
            case Development:
                return "chat-dev.nudj.co"
            }
        }
        
        var charConferenceDomain: String {
            return "conference." + chatHostname 
        }
        
        var description: String {
            return self.rawValue
        }
    }
}

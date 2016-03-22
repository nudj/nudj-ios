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
    
    init(url: NSURL) {
        self = .None
    }
}

public func == (lhs: Destination, rhs: Destination) -> Bool {
    switch lhs {
    case .None:
            switch rhs {
            case .None: return true
            default: return false
        }
        
    case .Job(let lhsID):
        switch rhs {
        case .Job(let rhsID): return lhsID == rhsID
        default: return false
        }
    }
}

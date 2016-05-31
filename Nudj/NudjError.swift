//
//  NudjError.swift
//  Nudj
//
//  Created by Richard Buckle on 31/05/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

enum NudjError: Int {
    case AuthenticationFailure = 1
    
    static let domain = "NudjError"
    
    func localizedDescription() -> String {
        switch self {
        case .AuthenticationFailure:
            return Localizations.Chat.Authentication.Error.Description
        }
    }
}

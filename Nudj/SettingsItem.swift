//
//  SettingsItem.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation

struct SettingsItem {
    let name: String
    let action: String // TODO: should be an Enum not a String

    init(name:String, action:String) {
        self.name = name;
        self.action = action;
    }
}

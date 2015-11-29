//
//  SettingsItem.swift
//  Nudj
//
//  Created by Lachezar Todorov on 29.04.15.
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation

struct SettingsItem {
    let name: String
    let action: String

    init(name:String, action:String) {
        self.name = name;
        self.action = action;
    }
}

//
//  SettingsItem.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation

struct SettingsItem {
    let name: String
    let action: SettingsController.CellAction

    init(name: String, action: SettingsController.CellAction) {
        self.name = name;
        self.action = action;
    }
}

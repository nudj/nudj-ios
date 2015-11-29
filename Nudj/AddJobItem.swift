//
//  SettingsItem.swift
//  Nudj
//
//  Created by Lachezar Todorov on 29.04.15.
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation

struct AddJobItem {
    let image: String
    let placeholder: String
    let type: AddJobbCellType

    init(type: AddJobbCellType, image:String, placeholder:String) {
        self.image = image;
        self.placeholder = placeholder;
        self.type = type;
    }
}

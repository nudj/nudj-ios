//
//  UserModel.swift
//  Nudge
//
//  Created by Lachezar Todorov on 26.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation

class UserModel {

    var id: Int32?
    var name: String?
    var token: String?
    var completed: Bool = false
    var addressBookAccess = false
    var status: Int32? = 0

    init() {
        
    }

    init(id: Int32?, name: String?, token: String?) {
        self.id = id;
        self.name = name;
        self.token = token;
    }

}
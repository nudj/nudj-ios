//
//  ContactModel.swift
//  Nudge
//
//  Created by Lachezar Todorov on 9.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import SwiftyJSON

class ContactModel {
    let id: Int
    var name: String
    var apple_id: Int?
    var user:UserModel?

    init(id:Int, name:String, apple_id:Int?, user:UserModel? = nil) {
        self.id = id
        self.name = name
        self.user = user

        if (apple_id != nil && apple_id! > 0) {
            self.apple_id = apple_id
        }
    }

    static func getContacts(closure: (Bool, JSON) -> ()) {
        API.sharedInstance.get("contacts?params=contact.alias,contact.user,contact.apple_id,user.image,user.status&sizes=user.profile", params: nil, closure: { result in
            closure(true, result)
            })
    }
}
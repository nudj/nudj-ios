//
//  ContactModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import SwiftyJSON

class ContactModel {
    let id: Int
    var name: String
    var apple_id: String?
    var user:UserModel?

    init(id:Int, name:String, apple_id:String?, user:UserModel? = nil) {
        self.id = id
        self.name = name
        self.user = user
        self.apple_id = apple_id
    }

    static func getContacts(closure: (Bool, JSON) -> ()) {
        // TODO: API strings
        API.sharedInstance.get("contacts/mine?params=contact.alias,contact.user,contact.apple_id,user.image,user.status&sizes=user.profile", params: nil, closure: { result in
            closure(true, result)
            })
    }
}

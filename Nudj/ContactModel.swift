//
//  ContactModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ContactModel {
    let id: Int
    let name: String
    let apple_id: String
    let user: UserModel?
    // TODO: add optional thumbnail image here

    init(id: Int, name: String, apple_id: String, user: UserModel?) {
        self.id = id
        self.name = name
        self.user = user
        self.apple_id = apple_id
    }

    static func getContacts(closure: (Bool, JSON) -> ()) {
        // TODO: API strings
        let path = API.Endpoints.Contacts.mine
        let params = API.Endpoints.Contacts.paramsForList(["contact.user"])
        API.sharedInstance.request(.GET, path: path, params: params, closure: { 
            result in
            closure(true, result)
            })
    }
}

// Equatable
func == (lhs: ContactModel, rhs: ContactModel) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name && lhs.apple_id == rhs.apple_id
}

extension ContactModel: Hashable {
    var hashValue: Int {
        return id.hashValue ^ name.hashValue ^ apple_id.hashValue
    }
}

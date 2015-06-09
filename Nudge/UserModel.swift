//
//  UserModel.swift
//  Nudge
//
//  Created by Lachezar Todorov on 26.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class UserModel: Printable {

    var id: Int32?
    var name: String?
    var token: String?
    var completed: Bool = false
    var addressBookAccess = false
    var status: Int32? = 0

    var description:String {
        return "UserModel: id: \(id), name: \(name), completed: \(completed ? 1 : 0), status: \(status)"
    }

    init() {
        
    }

    init(id: Int32?, name: String?, token: String?) {
        self.id = id;
        self.name = name;
        self.token = token;
    }

    static func getCurrent(fields:[String]?, closure: ((JSON) -> ())? = nil, errorHandler: ((NSError) -> Void)? = nil) {
        UserModel.getById(0, fields: fields, closure: closure, errorHandler: errorHandler)
    }

    static func getById(id: Int, fields:[String]?, closure: ((JSON) -> ())? = nil, errorHandler: ((NSError) -> Void)? = nil ) {
        let params = [String: AnyObject]()

        let block = closure == nil
            ? { _ in }
            : closure

        let userFields = (fields == nil)
            ? ""
            : ",".join(fields!)

        let userId = id <= 0
            ? "me"
            : "\(id)"

        API.sharedInstance.request(Alamofire.Method.GET, path: "users/\(userId)?params=\(userFields)", params: params, closure: closure!, errorHandler: errorHandler)
    }

}
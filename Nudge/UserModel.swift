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

    var id: Int?

    var name: String?
    var token: String?
    var about: String?

    var completed: Bool = false
    var addressBookAccess = false
    var status: Int? = 0

    var skills:[String]?
    var image:[String:String] = ["profile": "http://usr-img.doppels.com/place_holder_grey.png"]
    var isDefaultImage = true

    var description:String {
        return "UserModel: id: \(id), name: \(name), completed: \(completed ? 1 : 0), status: \(status)"
    }

    init() {
        
    }

    init(id: Int?, name: String?, token: String?) {
        self.id = id;
        self.name = name;
        self.token = token;
    }

    static func getLocal(closure: ((UserModel?) -> ())) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        closure(appDelegate.user)
    }

    static func getCurrent(fields:[String]?, closure: ((UserModel) -> ())? = nil, errorHandler: ((NSError) -> Void)? = nil) {
        UserModel.getById(0, fields: fields, closure: {response in
            let userResponse = response["data"]

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            var user = appDelegate.user == nil ? UserModel() : appDelegate.user!

            let mirror = reflect(user);

            user.updateFromJson(userResponse)

            closure?(user)

        }, errorHandler: errorHandler)
    }

    func updateFromJson(source: JSON) {
        for (key: String, subJson: JSON) in source {
            switch key {
                case "id": self.id = subJson.intValue
                case "status": self.status = subJson.intValue

                case "name": self.name = subJson.stringValue
                case "token": self.token = subJson.stringValue
                case "about": self.about = subJson.stringValue

                case "image": self.updateImageFromJson(subJson)
                case "skills": self.skills = subJson.arrayValue.map({return $0["name"].stringValue})

                case "completed": self.completed = subJson.boolValue
                // addressBookAccess is per device, so it should not be updated trough this method

            default:
                println("!!!! Unknown user key: " + key)
            }
        }
    }

    func updateImageFromJson(source:JSON) {
        for (key,val) in source.dictionaryValue {
            println(key, val)
            self.image[key] = val.stringValue;
            self.isDefaultImage = true
        }
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

    static func update(fields: [String: AnyObject], closure: ((JSON) -> ())? = nil, errorHandler: ((NSError) -> Void)? = nil) {
        let realClosure = (closure != nil) ? closure! : { _ in }
        let realErrorHandler = (errorHandler != nil) ? errorHandler! : { error in println(error) }

        API.sharedInstance.put("users/me", params: fields, closure: realClosure, errorHandler: realErrorHandler)
    }

}
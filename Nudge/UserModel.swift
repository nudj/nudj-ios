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
import AddressBook

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
    var base64Image:String?
    
    var description:String {
        return "UserModel: id: \(id), name: \(name), completed: \(completed ? 1 : 0), status: \(status), image:\(image)"
    }

    var company:String?
    var address:String?
    var position:String?
    var email:String?

    var favourite:Bool?

    var source:JSON?

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

    static func getLocal() -> UserModel? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        return appDelegate.user
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
        self.source = source
        
        for (key: String, subJson: JSON) in source {
            switch key {
            case "id": id = subJson.intValue
            case "status": status = subJson.intValue

            case "name": name = subJson.stringValue
            case "token": token = subJson.stringValue
            case "about": about = subJson.stringValue

            case "company": company = subJson.stringValue
            case "address": address = subJson.stringValue
            case "position": position = subJson.stringValue
            case "email": email = subJson.stringValue

            case "image": updateImageFromJson(subJson)
            case "skills": skills = subJson.arrayValue.map({return $0["name"].stringValue})

            case "completed": completed = subJson.boolValue
            // addressBookAccess is per device, so it should not be updated trough this method

            case "favourite": favourite = subJson.boolValue

            default:
                println("!!!! Unknown user key: " + key)
            }
        }
    }

    func updateImageFromJson(source:JSON) {
        
        for (key,val) in source.dictionaryValue {
            
            self.image[key] = val.stringValue;
            self.isDefaultImage = false
            
        }
        
        if let url = NSURL(string :self.image["profile"]!){
            var imageData = NSData(contentsOfURL: url)
                if imageData != nil {
                    let base64String = imageData!.base64EncodedStringWithOptions(.allZeros)
                    self.base64Image = base64String
                }
        }
        println("updated user image")
        
    }

    func toggleFavourite(closure: (JSON) -> (), errorHandler: ((NSError) -> Void)? = nil) {
        if (id == nil) {
            println("Invalid User ID!")
            return;
        }

        let url = "users/\(id!)/favourite"
        let method = (favourite == nil || (favourite!) == false) ? Method.PUT : Method.DELETE

        API.sharedInstance.request(method, path: url, params: nil, closure: closure, errorHandler: errorHandler)
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
        let realErrorHandler = (errorHandler != nil) ? errorHandler! : { error in println("Strange Error: \(error)") }

        API.sharedInstance.put("users/me", params: fields, closure: realClosure, errorHandler: realErrorHandler)
    }

    static func getImageByContactId(contactId:Int) -> UIImage? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

        return appDelegate.contacts.getContactImageForId(contactId)
    }

    static func getDefaultUserImage() -> UIImage? {
        return UIImage(named: "user_image_placeholder")
    }

}
//
//  UserModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import SwiftyJSON
import AddressBook

class UserModel: CustomStringConvertible {
    enum Notifications: String {
        case BlockedUsersChanged, BlockedJobsChanged
        
        func post(toCenter center: NSNotificationCenter, forUser user: UserModel) {
            center.postNotificationName(self.rawValue, object: user)
        }
    }
    
    enum ImageSize {
        case Size50, Size60
        
        func ImageName() -> String {
            switch self {
            case Size50:
                return "User image placeholder 50x50"
                
            case Size60:
                return "User image placeholder 60x60"
            }
        }
    }
    
    typealias ErrorHandler = (ErrorType) -> Void

    var id: Int?

    var name: String?
    var token: String?
    var about: String?

    var completed: Bool = false
    var addressBookAccess = false
    var status: Int? = 0

    var skills:[String]?
    var image:[String: String]
    var isDefaultImage = true
    var base64Image:String?
    
    var description:String {
        return "UserModel: id: \(id), name: \(name), completed: \(completed ? 1 : 0), status: \(status), image:\(image), blocked:\(blockedUserIDs)"
    }

    static let fieldsForProfile = [
        "user.name", 
        "user.about", 
        "user.company", 
        "user.address", 
        "user.position", 
        "user.email", 
        "user.skills", 
        "user.status",
        "user.image", 
        "user.favourite",
    ]
    
    var company:String?
    var address:String?
    var position:String?
    var email:String?

    var favourite:Bool?

    var source:JSON?
    var settings:JSON?
    
    var blockedUserIDs = Set<Int>() {
        didSet {
            let notification = Notifications.BlockedUsersChanged
            notification.post(toCenter: NSNotificationCenter.defaultCenter(), forUser: self)
        }
    }

    var blockedJobIDs = Set<Int>() {
        didSet {
            let notification = Notifications.BlockedJobsChanged
            notification.post(toCenter: NSNotificationCenter.defaultCenter(), forUser: self)
        }
    }

    init(id: Int? = nil, name: String? = nil, token: String? = nil) {
        self.id = id;
        self.name = name;
        self.token = token;
        let api = API()
        self.image = ["profile": api.server.URLString + API.Endpoints.PlaceHolders.defaultUserImage]
    }

    static func getLocal(closure: ((UserModel?) -> ())) {
        // TODO: remove singleton access
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        closure(appDelegate.user)
    }

    static func getLocal() -> UserModel? {
        // TODO: remove singleton access
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        return appDelegate.user
    }

    static func getCurrent(fields:[String], closure: ((UserModel) -> ())? = nil, errorHandler: ErrorHandler? = nil) {
        UserModel.getById(0, fields: fields, closure: {response in
            let userResponse = response["data"]

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            let user = appDelegate.user
            user.updateFromJson(userResponse)
            closure?(user)
        }, errorHandler: errorHandler)
    }
    
    func updateFromJson(source: JSON) {
        self.source = source
        
        for (key, subJson) in source {
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
            case "settings": settings = subJson

            default:
                // TODO: better error handling
                loggingPrint("!!!! Unknown user key: " + key)
            }
        }
    }

    func updateImageFromJson(source:JSON) {
        for (key, val) in source.dictionaryValue {
            self.image[key] = val.stringValue;
            self.isDefaultImage = false
        }
        
        if let url = NSURL(string :self.image["profile"]!){
            if let imageData = NSData(contentsOfURL: url) {
                let base64String = imageData.base64EncodedStringWithOptions([])
                self.base64Image = base64String
            }
        }
    }
    
    func fetchBlockedUsers() {
        API.sharedInstance.request(.GET, path: API.Endpoints.Users.blocked, params: nil, closure: {
            json in
            // TODO: API strings
            let newBlockedIDs = json["data"]["ids"].arrayValue.map({$0.intValue})
            self.blockedUserIDs = Set<Int>(newBlockedIDs)
        })
    }
    
    func hasFullyCompletedProfile() -> Bool {
        if name?.isEmpty ?? true {return false}
        if email?.isEmpty ?? true {return false}
        if company?.isEmpty ?? true {return false}
        if skills?.isEmpty ?? true {return false}
        if position?.isEmpty ?? true {return false}
        if about?.isEmpty ?? true {return false}
        if address?.isEmpty ?? true {return false}
        
        return true
    }

    func toggleFavourite(closure: (JSON) -> (), errorHandler:ErrorHandler? = nil) {
        if (id == nil) {
            loggingPrint("Invalid User ID!")
            return
        }

        let path = API.Endpoints.Users.favouriteByID(id)
        let method = (favourite ?? false) ? API.Method.DELETE : API.Method.PUT;
        API.sharedInstance.request(method, path: path, params: nil, closure: closure, errorHandler: errorHandler)
    }

    static func getById(id: Int, fields:[String], closure: ((JSON) -> ())? = nil, errorHandler: ErrorHandler? = nil ) {
        let path = API.Endpoints.Users.byID(id)
        let params = API.Endpoints.Users.paramsForFields(fields)
        API.sharedInstance.request(.GET, path: path, params: params, closure: closure, errorHandler: errorHandler)
    }

    static func update(fields: [String: AnyObject], closure: ((JSON) -> ())? = nil, errorHandler: ErrorHandler? = nil) {
        let path = API.Endpoints.Users.me
        API.sharedInstance.request(.PUT, path: path, params: fields, closure: closure, errorHandler: errorHandler)
    }
    
    static func getImageByContactId(identifier: String, size: ImageSize) -> UIImage {
        // TODO: remove singleton access
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        return appDelegate.contacts.getContactImageForId(identifier) ?? getDefaultUserImage(size)
    }

    static func getDefaultUserImage(size: ImageSize) -> UIImage {
        return UIImage(named: size.ImageName())!
    }
}

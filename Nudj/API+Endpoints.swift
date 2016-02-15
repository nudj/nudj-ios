//
//  API+Endpoints.swift
//  Nudj
//
//  Created by Richard Buckle on 15/02/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import Foundation

extension API {
    struct Endpoints {
        static let versionPath = "api/v1/"
        
        struct Chat {
            static let base = "chat"
            
            static func byID(chatID: Int) -> String {
                return base + "/\(chatID)"
            }
            
            static func all() -> String {
                return base + "/all"
            }
            
            static func active() -> String {
                return base + "/active"
            }
            
            static func archived() -> String {
                return base + "/archived"
            }
            
            static func notification() -> String {
                return base + "/notification"
            }
            
            static func archiveByID(chatID: Int) -> String {
                let chatPath = byID(chatID)
                return chatPath + "/archive"
            }
            
            static func paramsForLimit(pageSize: Int) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "limit": pageSize
                ]
                return params
            }
            
            static func paramsForList(pageSize: Int) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "params": "chat.job,job.liked,chat.participants,chat.created,job.title,job.company,job.like,user.image,user.name,user.contact,contact.alias",
                    "limit": pageSize
                ]
                return params
            }
            
            static func paramsForMessage(chatID: Int, userID: Int, message: String) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "chat_id": chatID,
                    "user_id": userID,
                    "message": message,
                ]
                return params
            }
        }
        
        struct Config {
            static let base = "config"
            static let status = base + "/status"
        }
        
        struct Jobs {
            static let base = "jobs"
            static let available = base + "/available"
            
            static func byID(jobID: Int) -> String {
                return base + "/\(jobID)"
            }
            
            static func byFilter(filter: String) -> String {
                return base + "/\(filter)"
            }
            
            static func likeByID(jobID: Int) -> String {
                let jobPath = byID(jobID)
                return jobPath + "/like"
            }
            
            static func search(searchTerm: String?) -> String {
                guard let searchTerm = searchTerm else {
                    return available
                }
                return base + "/search/\(searchTerm)"
            }
            
            static func paramsForList(page: Int, pageSize: Int) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "params": "job.title,job.salary,job.bonus,job.user,job.location,job.company,user.name,user.image",
                    "sizes": "user.profile",
                    "page": page,
                    "limit": pageSize
                ]
                return params
            }
            
            static func paramsForDetail() -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "params": "job.title,job.company,job.liked,job.salary,job.active,job.description,job.skills,job.bonus,job.user,job.location,user.image,user.name,user.contact"
                ]
                return params
            }
        }
        
        struct Users {
            static let base = "users"
            static let me = base + "/me"
            
            static func byID(userID: Int?) -> String {
                guard let userID = userID else {
                    return me
                }
                guard userID > 0 else {
                    return me
                }
                return base + "/\(userID)"
            }
            
            static func favouriteByID(userID: Int?) -> String {
                let userPath = byID(userID) 
                return userPath + "/favourite"
            }
            
            static func paramsForFields(fields: [String]) -> [String: String] {
                let userFields = fields.reduce("", combine: {$0! + "," + $1}) ?? ""
                return ["params": userFields]
            }
            
            static func paramsForStatuses() -> [String: String] {
                return ["params": "user.status,user.facebook"]
            }
            
            static let verify = base + "/verify"
            
            static func paramsForLogin(phoneNumber: String, iso2CountryCode: String) -> [String: String] {
                return [
                    "phone": phoneNumber,
                    "country_code": iso2CountryCode
                ]
            }
            
            static func paramsForVerify(phoneNumber: String, iso2CountryCode: String, verificationCode: String) -> [String: String] {
                return [
                    "phone": phoneNumber,
                    "country_code": iso2CountryCode,
                    "verification": verificationCode
                ]
            }
            
            static func paramsForResendVerification(phoneNumber: String) -> [String: String] {
                return [
                    "phone": phoneNumber
                ]
            }
        }
        
        struct PlaceHolders {
            static let defaultUserImage = "app/placeholder/user.png"
        }
    }
}

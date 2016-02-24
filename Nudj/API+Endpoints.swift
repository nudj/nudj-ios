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
        
        struct Connect {
            static let base = "connect"
            
            static func byPath(path: String) -> String {
                return "\(base)/\(path)"
            }
            
            static func paramsForToken(token: String) -> [String: AnyObject] {
                return ["token": token]
            }
        }
        
        struct Contacts {
            static let base = "contacts"
            static let mine = base + "/mine"
            
            static func paramsForList(fields: [String]) -> [String: AnyObject] {
                let allFields = fields + ["contact.alias", "contact.apple_id", "user.image", "user.status", "user.name"]
                let fieldsString = allFields.joinWithSeparator(",")
                let params: [String: AnyObject] = [
                    "params": fieldsString,
                    "sizes": "user.profile",
                ]
                return params
            }
            
            static func byID(contactID: Int) -> String {
                return base + "/\(contactID)"
            }
            
            static func inviteByID(contactID: Int) -> String {
                let contactPath = byID(contactID)
                return contactPath + "/invite"
            }
        }
        
        struct Devices {
            static let base = "devices"
            
            static func params(deviceToken: String) -> [String: String] {
                let params = ["token": deviceToken]
                return params
            }
        }
        
        struct Feedback {
            static let base = "feedback"
            
            static func params(message: String) -> [String: String] {
                let params = ["feedback": message]
                return params
            }
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
            
            static func blockByID(jobID: Int) -> String {
                let jobPath = byID(jobID)
                return jobPath + "/block"
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
        
        struct Notifications {
            static let base = "notifications"
            static let test = base + "/test"
            
            static func byID(id: AnyObject) -> String {
                return base + "/\(id)"
            }
            
            static func markReadByID(id: String) -> String {
                let path = byID(id)
                return path + "/read"
            }
            
            static func paramsForList(pageSize: Int) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "params": "chat.id,sender.name,sender.image",
                    "limit": pageSize,
                ]
                return params
            }
        }
        
        struct Nudge {
            static let base = "nudge"
            static let apply = base + "/apply"
            static let ask = base + "/ask"
            static let chat = base + "/chat"
           
            static func paramsForJob(jobID: Int, contactIDs: [Int], message: String) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "job": jobID,
                    "contacts": contactIDs,
                    "message": message,
                ]
                return params
            }
            
            static func paramsForApplication(jobID: Int) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "job_id": jobID,
                ]
                return params
            }
            
            static func paramsForChat(jobID: Int, userID: Int, notificationID: String, message: String) -> [String: AnyObject] {
                let params: [String: AnyObject] = [
                    "job_id": jobID,
                    "user_id": userID,
                    "notification_id": notificationID,
                    "message": message,
                ]
                return params
            }
        }
        
        struct ReportAbuse {
            static let base = "report-abuse"
            
            static func params(message: String) -> [String: String] {
                let params = ["abuse": message]
                return params
            }
        }
        
        struct Users {
            static let base = "users"
            static let me = base + "/me"
            static let blocked = base + "/blocked"
            
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
            
            static func blockByID(userID: Int) -> String {
                let userPath = byID(userID)
                return userPath + "/block"
            }
            
            static func reportByID(userID: Int) -> String {
                let userPath = byID(userID)
                return userPath + "/report"
            }
            
            static func paramsForFields(fields: [String]) -> [String: String] {
                let fieldsString = fields.joinWithSeparator(",")
                return ["params": fieldsString]
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

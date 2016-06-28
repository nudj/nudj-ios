//
//  JobModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import SwiftyJSON

struct JobModel {
    // TODO: revisit error handling
    private struct UnknownError: ErrorType {}

    var title: String
    var description: String
    var salaryFreeText: String
    var company: String
    var location: String
    var bonusAmount: Int
    var bonusCurrency: String
    var active: Bool
    var skills: [String]
    
    let locale: NSLocale
    var currencyFormatter: NSNumberFormatter {
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.locale = locale
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.currencyCode = bonusCurrency
        return currencyFormatter
    }
    
    var formattedBonus: String {
        let formattedBonus = currencyFormatter.stringFromNumber(bonusAmount) ?? "\(bonusCurrency) \(bonusAmount)"
        return formattedBonus
    }
    
    init(json: JSON, locale: NSLocale = NSLocale.autoupdatingCurrentLocale()) {
        title = json["title"].stringValue
        description = json["description"].stringValue
        salaryFreeText = json["salary"].stringValue
        company = json["company"].stringValue
        location = json["location"].stringValue
        bonusAmount = json["bonus"].intValue
        bonusCurrency = json["bonus_currency"].string ?? "GBP" // due to a server bug the currency code is being returned as integer 0
        active = json["active"].boolValue
        skills = json["skills"].arrayValue.map{$0["name"].stringValue}
        self.locale = locale
    }
    
    init(title: String, description: String, salaryFreeText: String, company: String, location: String, bonusAmount: Int, bonusCurrency: String, active: Bool, skills: [String], locale: NSLocale = NSLocale.autoupdatingCurrentLocale()) {
        self.title = title
        self.description = description
        self.salaryFreeText = salaryFreeText
        self.company = company
        self.location = location
        self.bonusAmount = bonusAmount
        self.bonusCurrency = bonusCurrency
        self.active = active
        self.skills = skills
        self.locale = locale
    }
    
    func params() -> [String: AnyObject] {
        let params:[String: AnyObject] = [
            "title": self.title,
            "description": self.description,
            "salary": self.salaryFreeText,
            "company": self.company,
            "location": self.location,
            "bonus": self.bonusAmount,
            "bonus_currency": self.bonusCurrency,
            "active": self.active ? 1 : 0,
            "skills": self.skills
        ]
        return params
    }

    func save(closure:(ErrorType?, Int) -> ()) {
        let path = API.Endpoints.Jobs.base
        let params = self.params()
        API.sharedInstance.request(.POST, path: path, params: params, closure: { 
            result in
            if (result["data"]["id"].intValue > 0) {
                closure(nil, result["data"]["id"].intValue)
            } else {
                closure(UnknownError(), 0)
            }
        }) { 
            error in
            closure(error, 0)
        }
    }
    
    func edit(jobID:Int, closure:(Bool) -> ()) {
        let path = API.Endpoints.Jobs.byID(jobID)
        let params = self.params()
        API.sharedInstance.request(.PUT, path: path, params: params, closure: { 
            result in
            closure(true)
        }, errorHandler: { 
            error in
            closure(false)
        })
    }
}

//
//  JobModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation

struct JobModel {
    // TODO: revisit error handling
    private struct UnknownError: ErrorType {}

    var title:String
    var description: String
    var salaryFreeText: String
    var company: String
    var location: String
    var bonusAmount: Int
    var bonusCurrency: String
    var active: Bool
    var skills: [String]
    
    func params() -> [String: AnyObject] {
        let params:[String: AnyObject] = [
            "title": self.title,
            "description": self.description,
            "salary": self.salaryFreeText,
            "company": self.company,
            "location": self.location,
            "bonus": self.bonusAmount,
            "bonus_currency": self.bonusCurrency,
            "active": self.active ? "1" : "0",
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

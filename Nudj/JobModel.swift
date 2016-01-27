//
//  JobModel.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation

class JobModel {
    // TODO: revisit error handling
    private struct UnknownError: ErrorType {}

    var title:String = ""
    var description: String = ""
    var salary: String = ""
    var company: String = ""
    var location: String = ""
    var bonus: String = ""
    var active: Bool = true
    var skills: [String] = []
    
    func params() -> [String: AnyObject] {
        let params:[String: AnyObject] = [
            "title": self.title,
            "description": self.description,
            "salary": self.salary,
            "company": self.company,
            "location": self.location,
            "bonus": self.bonus,
            "active": self.active ? "1" : "0",
            "skills": self.skills
        ]
        return params
    }

    func save(closure:(ErrorType?, Int) -> ()) {
        let params = self.params()

        // TODO: API strings
        API.sharedInstance.post("jobs", params: params, closure: { result in
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
        let params = self.params()

        // TODO: API strings
        API.sharedInstance.put("jobs/\(jobID)", params: params, closure: { 
            result in
            closure(true)
        }, errorHandler: { 
            error in
            closure(false)
        })
    }

}
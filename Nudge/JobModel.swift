//
//  JobModel.swift
//  Nudge
//
//  Created by Lachezar Todorov on 8.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation

class JobModel {

    var title:String = ""
    var description: String = ""
    var salary: String = ""
    var company: String = ""
    var location: String = ""
    var bonus: String = ""
    var active: Bool = true
    var skills: [String] = []

    func save(closure:(NSError?, Int) -> ()) {
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

        API.sharedInstance.post("jobs", params: params, closure: { result in
            if (result["data"]["id"].intValue > 0) {
                closure(nil, result["data"]["id"].intValue)
            } else {
                closure(NSError(), 0)
            }
        }) { error in
            closure(error, 0)
        }
    }
    
    func edit(jobID:Int, closure:(Bool) -> ()) {
        
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
        
        API.sharedInstance.put("jobs/\(jobID)", params: params, closure: { result in
            print("jobs success -> /\(result)")
            closure(true)
        }, errorHandler: { error in
            closure(false)
        })
         
    }

}
//
//  ChatListTableViewCell.swift
//  Nudge
//
//  Created by Antonio on 22/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet var profilePicture: AsyncImage!
    @IBOutlet var userName: UILabel!
    @IBOutlet var timeAgo: UILabel!
    @IBOutlet weak var jobCompany: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    
    
    func loadData(data:JSON) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let job = data["job"]
        
        let user = data["participants"][0]["id"].intValue == appDelegate.user!.id ? data["participants"][1] : data["participants"][0]
        
        profilePicture.downloadImage(user["image"]["profile"].stringValue)

        userName.text = user["name"].string
        jobTitle.text = job["title"].string
        jobCompany.text = job["company"].string

        timeAgo.text = data["created"].string
    }
    
}

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
    
    func loadData(data:ChatStructModel) {
        
        if let job = data.job{
            userName.text = data.participantName
            jobTitle.text = job["title"].string
            jobCompany.text = job["company"].string
        }
        
        profilePicture.setCustomImage(UserModel.getDefaultUserImage())
        profilePicture.downloadImage(data.image)
        
        timeAgo.text = data.time
        
        self.isRead(data.isRead!)
    }
    
    func isRead(value:Bool){
        
        if (!value){
            // TODO: magic numbers
            self.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        }else{
            self.backgroundColor = UIColor.whiteColor();
        }
    }
}

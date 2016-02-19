//
//  ChatListTableViewCell.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

final class ChatListTableViewCell: UITableViewCell {

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
        
        self.setRead(data.isRead!)
    }
    
    func setRead(isRead: Bool) {
        self.backgroundColor = isRead ? UIColor.whiteColor() : UIColor(white: 240.0/255.0, alpha: 1.0)
    }
}

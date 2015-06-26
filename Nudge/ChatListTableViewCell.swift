//
//  ChatListTableViewCell.swift
//  Nudge
//
//  Created by Antonio on 22/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var timeAgo: UILabel!
    @IBOutlet var jobTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//  NotificationCellTableViewCell.swift
//  Nudge
//
//  Created by Lachezar Todorov on 9.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

enum notificationType:Int {
    case AskToRefer = 1
    case NewApplication = 2
    case MatchingContact = 3
}

class NotificationCell: UITableViewCell {

    var type:Int = 0
    var messageText = ""
    var meta:JSON?
    var user: UserModel?

    @IBOutlet weak var profileImage: AsyncImage!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var message: UILabel!

    @IBOutlet weak var refLabel: UILabel!
    @IBOutlet weak var refAmount: UILabel!

    @IBOutlet weak var smsButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    func loadData(data:JSON) {
        
    }
    
}

//
<<<<<<< HEAD
//  NotificationCellTableViewCell.swift
//  Nudge
//
//  Created by Lachezar Todorov on 9.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationCell: UITableViewCell {


    func loadData(data:JSON) {
        
=======
//  NotificationCell.swift
//  Nudge
//
//  Created by Antonio on 03/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var referralBonus: UILabel!
    @IBOutlet var descriptionText: UILabel!
    @IBOutlet var actionButton: NotificationTypeButtons!
    
    @IBAction func buttonAction(sender: NotificationTypeButtons) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func buttonConfig(color :UIColor, withText text:String){
        self.actionButton.setupCustomButton(text, backgroundColor: color)
>>>>>>> origin/master
    }
    
}

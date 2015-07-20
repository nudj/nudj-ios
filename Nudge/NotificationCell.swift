//  NotificationCellTableViewCell.swift
//  Nudge
//
//  Created by Lachezar Todorov on 9.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol NotificationCellDelegate {
    func didPressDetailButton(cell:NotificationCell)
}

class NotificationCell: UITableViewCell {

    var delegate :NotificationCellDelegate?
    var type:Int = 0
    var messageText = ""
    var meta:JSON?
    var user: UserModel?

    @IBOutlet weak var profileImage: AsyncImage!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var message: NZLabel!

    @IBOutlet weak var refLabel: UILabel!
    @IBOutlet weak var refAmount: UILabel!

    @IBOutlet weak var smsButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    func setup(data:Notification) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        profileImage.downloadImage(data.profileImage, completion:nil)
        self.readStatus(data.readStatus!)
        
        switch(data.notificationType!){
        case .AskToRefer:
             self.callButton.hidden = true
             self.smsButton.setTitle("Details", forState: UIControlState.Normal)
             self.message.text = data.senderName! + ": " + data.jobMessage!
             
             // Referral Property
             let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 13)
             self.message.setFont(boldFont, string: data.senderName!)
             
             self.refLabel.hidden = false
             self.refAmount.hidden = false
             
             self.smsButton.addTarget(self, action: "detailsAction", forControlEvents:.TouchUpInside)
             
         break;
        case .NewApplication:
            self.callButton.hidden = true
            self.smsButton.setTitle("Message", forState: UIControlState.Normal)
            self.refLabel.hidden = false
            self.refAmount.hidden = false
         break;
        case .WebApplication:
            self.callButton.hidden = true
            self.smsButton.setTitle("Nudge", forState: UIControlState.Normal)
            self.smsButton.backgroundColor = appDelegate.appBlueColor
            self.refLabel.hidden = false
            self.refAmount.hidden = false
         break;
        case .MatchingContact:
            
         break;
        default:
         break;
        }
        
        
        
        
    }
    
    func readStatus(read:Bool){
        println("read status -> \(read)")

        /*if(read == false){
            self.contentView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        }else{
            self.contentView.backgroundColor = UIColor.whiteColor()
        }*/
        
    }
    
    func detailsAction(){
        
        delegate?.didPressDetailButton(self)
        
    }

    
    func messageAction(){
        
    }
    
    
    func nudgeAction(){
        
    }
    
    func smsAction(){
        
    }
    
    func callAction(){
        
    }
}

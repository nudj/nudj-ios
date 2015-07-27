//  NotificationCellTableViewCell.swift
//  Nudge
//
//  Created by Lachezar Todorov on 9.07.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol NotificationCellDelegate {
    func didPressRightButton(cell:NotificationCell)
    func didPressCallButton(cell:NotificationCell)
}


class NotificationCell: UITableViewCell {

    var delegate :NotificationCellDelegate?
    var type:NotificationType?
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

        profileImage.downloadImage(data.senderImage, completion:nil)
        self.message.text = data.notificationMessage
        
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 13)
        self.message.setFont(boldFont, string: data.senderName!)
        self.message.setFont(boldFont, string: data.jobTitle!)

        self.refAmount.text = data.jobBonus;
        self.readStatus(data.notificationReadStatus!)
        
        self.type = data.notificationType
        
        let timestamp:NSTimeInterval =  NSTimeInterval(data.notificationTime!)
        let date:NSDate = NSDate(timeIntervalSince1970:timestamp)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d/M/yy - H:mm"
        let currentDate  = dateFormatter.stringFromDate(date)
        
        self.dateLabel.text = currentDate
        
        self.smsButton.addTarget(self, action: "actions:", forControlEvents:.TouchUpInside)
        
        
        switch(data.notificationType!){
        case .AskToRefer:
             self.callButton.hidden = true
             self.smsButton.setTitle("Details", forState: UIControlState.Normal)
             self.refLabel.hidden = false
             self.refAmount.hidden = false
             
         break;
        case .AppApplication:
            self.callButton.hidden = true
            self.smsButton.setTitle("Message", forState: UIControlState.Normal)
            self.refLabel.hidden = false
            self.refAmount.hidden = false
         break;
        case .WebApplication:
         break;
        case .MatchingContact:
            self.callButton.hidden = true
            self.smsButton.setTitle("Nudge", forState: UIControlState.Normal)
            self.smsButton.backgroundColor = appDelegate.appBlueColor
            self.refLabel.hidden = false
            self.refAmount.hidden = false
          break;
        case .AppApplicationWithNoReferral:
            self.callButton.hidden = true
            self.smsButton.setTitle("Message", forState: UIControlState.Normal)
            self.refLabel.hidden = false
            self.refAmount.hidden = false
          break;
        case .WebApplicationWithNoReferral:
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
    
    func actions(sender:UIButton){
        
        delegate?.didPressRightButton(self)
        
    }
    
    @IBAction func callAction(sender: UIButton) {
        
         delegate?.didPressCallButton(self)
    }


}

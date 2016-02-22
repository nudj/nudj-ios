//  NotificationCellTableViewCell.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON
import DateTools

protocol NotificationCellDelegate {
    func didPressRightButton(cell:NotificationCell)
    func didPressCallButton(cell:NotificationCell)
    func didTapUserImage(cell:NotificationCell)
}


class NotificationCell: UITableViewCell {

    var delegate :NotificationCellDelegate?
    var type:NotificationType?
    var messageText = ""
    var meta:JSON?
    var isRead:Bool?
    var notificationData:Notification?
    var notificationID:String?
    var sender:UIButton?

    @IBOutlet weak var profileImage: AsyncImage!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var message: UILabel!

    @IBOutlet weak var refLabel: UILabel!
    @IBOutlet weak var refAmount: UILabel!

    @IBOutlet weak var smsButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    func setup(data:Notification) {
        
        self.notificationData = data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        profileImage.setCustomImage(UserModel.getDefaultUserImage())
        profileImage.downloadImage(data.senderImage, completion:nil)
        
        let tap = UITapGestureRecognizer(target:self, action:"ImageTap:")
        profileImage.addGestureRecognizer(tap)
        
        let messageString = data.notificationMessage ?? "" as NSString
        let messageAttibutedString = NSMutableAttributedString(string: messageString as String)
        if let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 13) {
            if let senderName = data.senderName {
                let range = messageString.rangeOfString(senderName)
                messageAttibutedString.addAttribute(NSFontAttributeName, value: boldFont, range: range)
            }
            if let jobTitle = data.jobTitle {
                let range = messageString.rangeOfString(jobTitle)
                messageAttibutedString.addAttribute(NSFontAttributeName, value: boldFont, range: range)
            }
        }
        message.attributedText = messageAttibutedString

        if(data.jobBonus!.isEmpty){
            self.refLabel.hidden = true
            self.refAmount.hidden = true
        }else{
            self.refAmount.text = data.jobBonus;
        }
        
        self.readStatus(data.notificationReadStatus!)
        
        self.type = data.notificationType
        self.notificationID = data.notificationId
        
        let timestamp:NSTimeInterval =  NSTimeInterval(data.notificationTime!)
        let date:NSDate = NSDate(timeIntervalSince1970:timestamp)
        self.dateLabel.text = date.timeAgoSinceNow()
        
        self.smsButton.addTarget(self, action: "actions:", forControlEvents:.TouchUpInside)
        
        switch(data.notificationType!){
        case .AskToRefer:
            self.callButton.hidden = true
            self.smsButton.setTitle(Localizations.Notification.Button.Details, forState: .Normal)
            self.refLabel.hidden = false
            self.refAmount.hidden = false
            break;
        case .AppApplication:
            self.callButton.hidden = true
            self.smsButton.setTitle(Localizations.Notification.Button.Message, forState: .Normal)
            self.refLabel.hidden = false
            self.refAmount.hidden = false
            break;
        case .WebApplication:
            break;
        case .MatchingContact:
            self.callButton.hidden = true
            self.smsButton.setTitle(Localizations.Notification.Button.Nudj, forState: .Normal)
            self.smsButton.backgroundColor = appDelegate.appColor
            self.refLabel.hidden = false
            self.refAmount.hidden = false
            break;
        case .AppApplicationWithNoReferral:
            self.callButton.hidden = true
            self.smsButton.setTitle(Localizations.Notification.Button.Message, forState: .Normal)
            self.refLabel.hidden = false
            self.refAmount.hidden = false
            break;
        case .WebApplicationWithNoReferral:
            break;
        }
    }
    
    func readStatus(read:Bool){
        self.isRead = read
        self.contentView.backgroundColor = read ? UIColor.whiteColor() : UIColor(white: 240.0/255.0, alpha: 1.0)
    }
    
    func actions(sender:UIButton){
        self.sender = sender
        delegate?.didPressRightButton(self)
    }
    
    @IBAction func callAction(sender: UIButton) {
         delegate?.didPressCallButton(self)
    }

    @IBAction func ImageTap(sender: UITapGestureRecognizer) {
        delegate?.didTapUserImage(self)
    }

    func markAsRead(){
        let path = API.Endpoints.Notifications.markReadByID(notificationID!)
        API.sharedInstance.request(.PUT, path: path, params: nil, closure: { json in
            loggingPrint("success \(json)")
        }) { 
            error in
            loggingPrint("error \(error)")
        }
    }
}

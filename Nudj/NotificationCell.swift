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

    var delegate: NotificationCellDelegate?
    var type: NotificationType?
    var messageText = ""
    var meta: JSON?
    var isRead: Bool = false {
        didSet {
            self.contentView.backgroundColor = isRead ? UIColor.whiteColor() : UIColor(white: 240.0/255.0, alpha: 1.0)
        }
    }
    var notificationData: Notification?
    var notificationID: String?
    var sender: UIButton?

    @IBOutlet weak var profileImage: AsyncImage!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var message: UILabel!

    @IBOutlet weak var refLabel: UILabel!
    @IBOutlet weak var refAmount: UILabel!

    @IBOutlet weak var smsButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    func setup(data: Notification) {
        self.notificationData = data

        profileImage.setCustomImage(UserModel.getDefaultUserImage(.Size60))
        profileImage.downloadImage(data.senderImage, completion:nil)
        
        let tap = UITapGestureRecognizer(target:self, action: #selector(didTapUserImage(_:)))
        profileImage.addGestureRecognizer(tap)
        
        let messageString = data.notificationMessage ?? "" as NSString
        let messageAttibutedString = NSMutableAttributedString(string: messageString as String)
        if let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 13) {
            let senderRange = messageString.rangeOfString(data.senderName)
            messageAttibutedString.addAttribute(NSFontAttributeName, value: boldFont, range: senderRange)
            let titleRange = messageString.rangeOfString(data.jobTitle)
            messageAttibutedString.addAttribute(NSFontAttributeName, value: boldFont, range: titleRange)
        }
        message.attributedText = messageAttibutedString

        if(data.jobBonus.isEmpty) {
            self.refLabel.hidden = true
            self.refAmount.hidden = true
        } else {
            self.refAmount.text = data.jobBonus
        }
        
        self.isRead = data.notificationReadStatus
        
        self.type = data.notificationType
        self.notificationID = data.notificationId
        
        let timestamp = NSTimeInterval(data.notificationTime)
        let date = NSDate(timeIntervalSince1970: timestamp)
        self.dateLabel.text = date.timeAgoSinceNow()
        
        self.smsButton.addTarget(self, action: #selector(actions(_:)), forControlEvents:.TouchUpInside)
        
        switch(data.notificationType) {
        case .AskToRefer:
            self.callButton.hidden = true
            self.smsButton.setTitle(Localizations.Notification.Button.Details, forState: .Normal)
            self.refLabel.hidden = false
            self.refAmount.hidden = false
        case .MatchingContact:
            self.callButton.hidden = true
            self.smsButton.setTitle(Localizations.Notification.Button.Nudj, forState: .Normal)
            self.smsButton.backgroundColor = ColorPalette.nudjGreen
            self.refLabel.hidden = false
            self.refAmount.hidden = false
        case .AppApplication, .AppApplicationWithNoReferral:
            self.callButton.hidden = true
            self.smsButton.setTitle(Localizations.Notification.Button.Message, forState: .Normal)
            self.refLabel.hidden = false
            self.refAmount.hidden = false
        case .WebApplication, .WebApplicationWithNoReferral:
            break
        }
    }
    
    func actions(sender:UIButton) {
        self.sender = sender
        delegate?.didPressRightButton(self)
    }
    
    @IBAction func didPressCallButton(sender: UIButton) {
         delegate?.didPressCallButton(self)
    }

    @IBAction func didTapUserImage(sender: UITapGestureRecognizer) {
        delegate?.didTapUserImage(self)
    }

    func markAsRead() {
        let path = API.Endpoints.Notifications.markReadByID(notificationID!)
        API.sharedInstance.request(.PUT, path: path, params: nil, closure: { json in
            loggingPrint("success \(json)")
        }) { 
            error in
            loggingPrint("error \(error)")
        }
    }
}

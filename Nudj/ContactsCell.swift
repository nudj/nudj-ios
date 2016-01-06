//
//  ContactsCell.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {

    @IBOutlet weak var profileImage: AsyncImage!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: StatusButton!

    var contactId:Int = 0
    
    func loadData(contact: ContactModel) {
        // TODO: MVC violation
        profileImage.setCustomImage(UserModel.getDefaultUserImage())
        
        if let user = contact.user {
            
            profileImage.downloadImage(user.image["profile"])

            if let statusIndex = user.status {
                status.setTitleByIndex(statusIndex)
                self.showStatus()
            } else {
                self.hideStatus()
            }

        } else {
            profileImage.setCustomImage(UserModel.getImageByContactId(contact.apple_id))

            self.hideStatus()
        }

        // Style
        accessoryType = UITableViewCellAccessoryType.None

        contactId = contact.id

        name.text = contact.name
    }

    func hideStatus() {
        if (status != nil) {
            status.hidden = true
            status.userInteractionEnabled = false
        }
    }

    func showStatus() {
        if (status != nil) {
            status.hidden = false
            status.userInteractionEnabled = true
        }
    }
    
    func removeSelectionStyle(){
        self.selectionStyle = UITableViewCellSelectionStyle.None;
    }

}

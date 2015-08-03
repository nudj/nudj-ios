//
//  ContactsCell.swift
//  Nudge
//
//  Created by Lachezar Todorov on 16.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class ContactsCell: DataTableCell {

    @IBOutlet weak var profileImage: AsyncImage!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: StatusButton!
    @IBOutlet weak var tick: UIImageView!

    var contactId:Int = 0

    var selectable = true

    override var selected:Bool {
        didSet {
            tick.highlighted = selected
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func loadData(contact: ContactModel) {


        if let user = contact.user {
            profileImage.downloadImage(user.image["profile"])

            if let statusIndex = user.status {
                status.setTitleByIndex(statusIndex)
                self.showStatus()
            } else {
                self.hideStatus()
            }

        } else {
            if let apple_id = contact.apple_id {
                profileImage.setCustomImage(UserModel.getImageByContactId(apple_id))
            }

            self.hideStatus()
        }

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

}

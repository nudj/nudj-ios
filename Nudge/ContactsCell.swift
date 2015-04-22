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

    override func loadData(data: JSON?) {
        println(data)
        if (data == nil) {
            return
        }

        if (data!["user"] != nil) {
            profileImage.downloadImage(data!["user"]["image"]["profile"].stringValue)

            let statusId = data!["user"]["status"].intValue
            
            if (status.isValidStatus(statusId)) {
                status.setTitleByIndex(statusId)
            } else {
                self.hideStatus()
            }

        } else {
            self.hideStatus()
        }

        name.text = data!["alias"].stringValue
    }

    func hideStatus() {
        if (status != nil && status.superview != nil) {
            status.removeFromSuperview()
        }
    }

}

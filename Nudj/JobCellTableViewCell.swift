//
//  JobCellTableViewCell.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON
import QuartzCore

class JobCellTableViewCell: UITableViewCell, DataTableCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var creatorImage: AsyncImage!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var bonusAmount: UILabel!
    @IBOutlet weak var location: UILabel!

    var gradient:CAGradientLayer? = nil

    func loadData(data:JSON?) {
        if (data == nil) {
            return
        }
        // TODO: API strings and MVC violation
        self.title.text = data!["title"].stringValue
        self.salary.text = data!["salary"].stringValue
        self.bonusAmount.text = "£" + data!["bonus"].stringValue
        self.creator.text = data!["user"]["name"].stringValue
        self.company.text = data?["company"].string

        self.location.text = data?["location"].string

        self.creatorImage.image = UserModel.getDefaultUserImage(.Size60)
        self.creatorImage.downloadImage(data!["user"]["image"]["profile"].stringValue)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None

        self.needsUpdateConstraints()
    }
    
}

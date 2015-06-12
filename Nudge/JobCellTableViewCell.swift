//
//  JobCellTableViewCell.swift
//  Nudge
//
//  Created by Lachezar Todorov on 11.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON
import QuartzCore

class JobCellTableViewCell: DataTableCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var creatorImage: AsyncImage!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var bonusAmount: UILabel!

    var gradient:CAGradientLayer? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func loadData(data:JSON?) {
        if (data == nil) {
            return
        }
        
        self.title.text = data!["title"].stringValue
        self.salary.text = data!["salary"].stringValue
        self.bonusAmount.text = "£" + data!["bonus"].stringValue
        self.creator.text = data!["user"]["name"].stringValue
        self.creatorImage.downloadImage(data!["user"]["image"]["profile"].stringValue)

        self.selectionStyle = UITableViewCellSelectionStyle.None

        self.needsUpdateConstraints()

        if (gradient == nil) {
            gradient = CAGradientLayer()
            gradient!.colors = [UIColor.whiteColor().CGColor, UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1).CGColor]
            gradient!.locations = [0.75, 1.0]

            println(frame)
            gradient!.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

            self.layer.insertSublayer(gradient, atIndex: 0)
        } else {
            println(frame)
            gradient!.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }

    }
    
}

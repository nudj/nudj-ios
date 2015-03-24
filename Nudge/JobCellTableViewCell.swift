//
//  JobCellTableViewCell.swift
//  Nudge
//
//  Created by Lachezar Todorov on 11.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit

class JobCellTableViewCell: DataTableCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var creatorImage: AsyncImage!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var bonusAmount: UILabel!

    override func loadData(data:JSON?) {
        if (data == nil) {
            return
        }
        
        self.title.text = data!["title"].stringValue
        self.salary.text = data!["salary"].stringValue
        self.bonusAmount.text = "£" + data!["bonus"].stringValue
        self.creator.text = data!["user"]["name"].stringValue
        self.creatorImage.downloadImage(data!["user"]["image"]["profile"].stringValue)
    }
    
}

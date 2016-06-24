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
    let locale = NSLocale.autoupdatingCurrentLocale()

    func loadData(data:JSON?) {
        guard let data = data else {
            return
        }
        // TODO: API strings and MVC violation
        
        // TODO: move formatting code to data model
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.locale = self.locale
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.currencyCode = data["bonus_currency"].stringValue
        
        self.title.text = data["title"].stringValue
        self.salary.text = data["salary"].stringValue
        self.bonusAmount.text = currencyFormatter.stringFromNumber(data["bonus"].intValue) ?? data["bonus"].stringValue
        self.creator.text = data["user"]["name"].stringValue
        self.company.text = data["company"].string

        self.location.text = data["location"].string

        self.creatorImage.image = UserModel.getDefaultUserImage(.Size60)
        self.creatorImage.downloadImage(data["user"]["image"]["profile"].stringValue)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None

        self.needsUpdateConstraints()
    }
    
}

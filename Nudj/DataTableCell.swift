//
//  DataTableCell.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

// TODO: I don't like this: rework it
protocol DataTableCell {
    func loadData(data:JSON?)
}

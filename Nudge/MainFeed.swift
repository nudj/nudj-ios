//
//  FirstViewController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 13.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainFeed: BaseController, DataProviderProtocol {

    @IBOutlet weak var table: DataTable!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.asignCellNib("JobCellTableViewCell")

        self.table.dataProvider = self as DataProviderProtocol
        self.table.delegate = self.table
        self.table.dataSource = self.table
        self.table.loadData()
    }

    func requestData(page: Int, size: Int, listener: (JSON) -> ()) {
        let url = "jobs?params=job.title,job.salary,job.bonus,job.user,user.name,user.image&sizes=user.profile&page=" + String(page) + "&limit=" + String(size)
        self.apiRequest(.GET, path: url, closure: listener)
    }

}


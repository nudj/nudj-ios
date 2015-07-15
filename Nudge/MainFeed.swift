//
//  FirstViewController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 13.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class MainFeed: BaseController, DataProviderProtocol {

    @IBOutlet weak var table: DataTable!

    var selectedJobData:JSON? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.asignCellNib("JobCellTableViewCell")

        self.table.dataProvider = self as DataProviderProtocol
        self.table.delegate = self.table
        self.table.dataSource = self.table
        self.table.selectedClosure = goToJob
        self.table.loadData()
        
    }

    func requestData(page: Int, size: Int, listener: (JSON) -> ()) {
        let url = "jobs/available?params=job.title,job.salary,job.bonus,job.user,job.location,job.company,user.name,user.image&sizes=user.profile&page=" + String(page) + "&limit=" + String(size)
        self.apiRequest(.GET, path: url, closure: listener)
    }

    func goToJob(job:JSON) {
        selectedJobData = job
        performSegueWithIdentifier("goToJob", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let askView = segue.destinationViewController as? AskReferralViewController {
            println(selectedJobData)
            askView.jobId = selectedJobData!["id"].stringValue.toInt()
        }
    }
}
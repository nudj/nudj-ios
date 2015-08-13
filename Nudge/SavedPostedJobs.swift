//
//  SavedPostedJobs.swift
//  Nudge
//
//  Created by Antonio on 29/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class SavedPostedJobs: BaseController, DataProviderProtocol {

    @IBOutlet weak var table: DataTable!
    
    var requestParams:String?
    var selectedJobData:JSON? = nil
    var noContentImage = NoContentPlaceHolder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.navigationController?.title = self.headerTitle
        self.table.asignCellNib("JobCellTableViewCell")
        
        self.table.dataProvider = self as DataProviderProtocol
        self.table.delegate = self.table
        self.table.dataSource = self.table
        self.table.selectedClosure = goToJob
        self.table.tableFooterView = UIView(frame: CGRectZero);
        
        self.table.loadData()
        self.view.addSubview(self.noContentImage.createNoContentPlaceHolder(self.view, imageTitle: "no_jobs"))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    func requestData(page: Int, size: Int, listener: (JSON) -> ()) {
        
        let url = "jobs/\(self.requestParams!)?params=job.title,job.salary,job.bonus,job.user,job.location,job.company,user.name,user.image&sizes=user.profile&page=" + String(page) + "&limit=" + String(size)
        
        println("jobs request \(url)")
        self.apiRequest(.GET, path: url, closure: listener)
    }
    
    func didfinishLoading(count:Int) {
        
        
        if(count == 0){
            
            self.noContentImage.showPlaceholder()
            
        }else{
            
            self.noContentImage.hidePlaceholder()
        }
        
    }
    
    func goToJob(job:JSON) {
        selectedJobData = job
        performSegueWithIdentifier("goToJob", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let askView = segue.destinationViewController as? AskReferralViewController {
            println(selectedJobData)
            askView.jobId = selectedJobData!["id"].stringValue.toInt()
        }else if let detailsView = segue.destinationViewController as? JobDetailedViewController {
            detailsView.jobID = selectedJobData!["id"].stringValue
            println(selectedJobData)
        }
        
    }
  

}

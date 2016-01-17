//
//  SavedPostedJobs.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class SavedPostedJobs: BaseController, SegueHandlerType, DataProviderProtocol {
    
    enum SegueIdentifier: String {
        case GoToJob = "goToJob"
    }

    @IBOutlet weak var table: DataTable!
    
    var requestParams:String?
    var selectedJobData:JSON? = nil
    var noContentImage = NoContentPlaceHolder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.navigationController?.title = self.headerTitle
        self.table.asignCellNib("JobCellTableViewCell")
        
        
        if self.requestParams != nil && self.requestParams! == "mine" {
            self.table.canEdit = true
        }
    
        self.table.dataProvider = self as DataProviderProtocol
        self.table.delegate = self.table
        self.table.dataSource = self.table
        self.table.selectedClosure = goToJob
        self.table.tableFooterView = UIView(frame: CGRectZero);
        
        self.table.loadData()
        self.view.addSubview(self.noContentImage.alignInSuperView(self.view, imageTitle: "no_jobs"))
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
        // TODO: API strings
        let url = "jobs/\(self.requestParams!)?params=job.title,job.salary,job.bonus,job.user,job.location,job.company,user.name,user.image&sizes=user.profile&page=" + String(page) + "&limit=" + String(size)
        
        loggingPrint("jobs request \(url)")
        self.apiRequest(.GET, path: url, closure: listener)
    }
    
    func deleteData(id: Int, listener: (JSON) -> ()) {
        loggingPrint("delete id\(id)")
        MixPanelHandler.sendData("JobDeleted")
        
        self.apiRequest(.DELETE, path: "jobs/\(id)", closure: listener)
    }
    
    func didfinishLoading(count:Int) {
        if(count == 0){
            self.noContentImage.hidden = false
        }else{
            self.noContentImage.hidden = true
        }
    }
    
    func goToJob(job:JSON) {
        selectedJobData = job
        performSegueWithIdentifier(.GoToJob, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .GoToJob:
            let detailsView = segue.destinationViewController as! JobDetailedViewController
            detailsView.jobID = selectedJobData!["id"].stringValue
        }
    }

}

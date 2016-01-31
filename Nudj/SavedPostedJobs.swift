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
    
    enum Query: String {
        case Liked = "liked"
        case Posted = "mine"
        
        func IsEditable() -> Bool {
            switch self {
            case .Posted:
                return true
                
            case .Liked:
                return false
            }
        }
    }

    @IBOutlet weak var table: DataTable!
    
    var queryType: Query = .Liked
    var selectedJobData:JSON? = nil
    var noContentImage = NoContentPlaceHolder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.navigationController?.title = self.headerTitle
        self.table.asignCellNib("JobCellTableViewCell")
        
        self.table.canEdit = self.queryType.IsEditable()
    
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
        let query = queryType.rawValue
        let url = "jobs/\(query)?params=job.title,job.salary,job.bonus,job.user,job.location,job.company,user.name,user.image&sizes=user.profile&page=\(page)&limit=\(size)"
        
        self.apiRequest(.GET, path: url, closure: listener)
    }
    
    func deleteData(id: Int, listener: (JSON) -> ()) {
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

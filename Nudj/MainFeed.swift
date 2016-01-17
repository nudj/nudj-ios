//
//  FirstViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON
//import ReachabilitySwift

@IBDesignable
class MainFeed: BaseController, DataProviderProtocol, UISearchBarDelegate, TutorialViewDelegate{

    @IBOutlet weak var table: DataTable!

    var selectedJobData:JSON? = nil

    @IBOutlet weak var searchBar: UISearchBar!
    var blackBackground = UIView()
    var searchTerm:String?
    var noContentImage = NoContentPlaceHolder()
    var tutorial = TutorialView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.asignCellNib("JobCellTableViewCell")
        self.table.dataProvider = self as DataProviderProtocol
        self.table.delegate = self.table
        self.table.dataSource = self.table
        self.table.selectedClosure = goToJob
        
        self.blackBackground.hidden = true
        self.blackBackground.alpha = 0.7
        self.blackBackground.backgroundColor = UIColor.blackColor()
        self.blackBackground.frame = self.view.frame
        self.view.addSubview(self.blackBackground)
        
        self.view.bringSubviewToFront(self.searchBar)
        self.view.addSubview(self.noContentImage.alignInSuperView(self.view, imageTitle: "no_jobs"))
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        if appDelegate.shouldShowAddJobTutorial  {
            tutorial.delegate = self
            tutorial.starTutorial("tutorial-welcome", view: self.view)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MixPanelHandler.sendData("JobsTabOpened")
        self.tabBarController?.tabBar.hidden = false
        
        if(searchTerm == nil){
            self.table.loadData()
        }
    }
    
    func requestData(page: Int, size: Int, listener: (JSON) -> ()) {
        // TODO: API strings
        let path = searchTerm == nil ? "available" : "search/\(searchTerm!)"
        self.noContentImage.image = searchTerm == nil ? UIImage(named:"no_jobs") : UIImage(named:"no_search_results")
        let params = "job.title,job.salary,job.bonus,job.user,job.location,job.company,user.name,user.image&sizes=user.profile"

        let url = "jobs/\(path)?params=\(params)&page=" + String(page) + "&limit=" + String(size)

        self.apiRequest(.GET, path: url, closure: listener)
    }
    
    func deleteData(id: Int, listener: (JSON) -> ()) {
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
        performSegueWithIdentifier("goToJob", sender: self) 
    }
    
    @IBAction func unwindToJobsList(segue: UIStoryboardSegue) {
        // nothing to do here
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let askView = segue.destinationViewController as? AskReferralViewController {
            askView.jobId = Int(selectedJobData!["id"].stringValue)
        }else if let detailsView = segue.destinationViewController as? JobDetailedViewController {
            detailsView.jobID = selectedJobData!["id"].stringValue
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.stopSearcAction()
        searchBar.text = ""
        searchTerm = nil
        self.table.loadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        //self.blackBackground.hidden = false
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchTerm = searchBar.text
        self.table.loadData()
        self.stopSearcAction()
    }
    
    func stopSearcAction(){
        //self.navigationController?.navigationBarHidden = false
        //self.searchBar.hidden = true
        searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
    }
    
    func dismissTutorial() {
        UserModel.update(["settings":["tutorial":["post_job":false]]], closure: { result in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.updateUserObject("AddJobTutorial", with:false)
            appDelegate.shouldShowAddJobTutorial = false
            
        })
    }
    
}

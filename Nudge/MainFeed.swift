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
class MainFeed: BaseController, DataProviderProtocol,UISearchBarDelegate {

    @IBOutlet weak var table: DataTable!

    var selectedJobData:JSON? = nil
    var searchBar =  UISearchBar()
    var blackBackground = UIView()
    var searchTerm:String?
    
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
        
        self.searchBar.hidden = true
        self.searchBar.delegate = self;
        self.searchBar.searchBarStyle = UISearchBarStyle.Default
        self.searchBar.showsCancelButton = true
        self.searchBar.showsScopeBar = true
        self.searchBar.frame = CGRectMake(0, 0, self.view.frame.width, 70)
        self.view.addSubview(self.searchBar)
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        self.table.loadData()
    }
    

    func requestData(page: Int, size: Int, listener: (JSON) -> ()) {

        let path = searchTerm == nil ? "available" : "search/\(searchTerm!)"
        let params = "job.title,job.salary,job.bonus,job.user,job.location,job.company,user.name,user.image&sizes=user.profile"

        let url = "jobs/\(path)?params=\(params)&page=" + String(page) + "&limit=" + String(size)

        self.apiRequest(.GET, path: url, closure: listener)
    }

    func goToJob(job:JSON) {
        selectedJobData = job
        performSegueWithIdentifier("goToJob", sender: self) 
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let askView = segue.destinationViewController as? AskReferralViewController {
            askView.jobId = selectedJobData!["id"].stringValue.toInt()
        }else if let detailsView = segue.destinationViewController as? JobDetailedViewController {
            detailsView.jobID = selectedJobData!["id"].stringValue
        }
        
    }
    @IBAction func searchAction(sender: UIBarButtonItem) {
        self.navigationController?.navigationBarHidden = true
        self.searchBar.hidden = false
        self.blackBackground.hidden = false
        self.searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        self.stopSearcAction()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchTerm = searchBar.text
        self.table.loadData()
        self.stopSearcAction()
        
    }
    
    func stopSearcAction(){
        
        self.navigationController?.navigationBarHidden = false
        self.searchBar.hidden = true
        self.blackBackground.hidden = true
        self.searchBar.resignFirstResponder()
        searchTerm = nil

    }
}
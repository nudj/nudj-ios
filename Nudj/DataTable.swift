//
//  DataTable.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

// TODO: MVC violation: separate out the UITableView, UITableViewDataSource, UITableViewDelegate
class DataTable: UITableView, UITableViewDataSource, UITableViewDelegate {

    var refreshControl:UIRefreshControl!
    let spaceToScroll:CGFloat = 400
    let nibName = "JobCellTableViewCell"
    let cellIdentifier = "NudgeCell"
    
    var dataSize = 20
    var page = 1
    var end = false
    var loading = false

    var dataProvider:DataProviderProtocol?
    var unfilteredData = [JSON]()
    var filteredData = [JSON]()
    var canEdit = false

    var selectedClosure:((JSON)->())? = nil

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        rowHeight = UITableViewAutomaticDimension

        delegate = self
        dataSource = self

        refreshControl = UIRefreshControl()
        
        // TODO: move refreshControl into IB
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        refreshControl.tintColor = appDelegate.appColor
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        addSubview(refreshControl)
        autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight]
        tableFooterView = UIView(frame: CGRectZero)
        
        self.registerNib(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }

    func loadData(page: Int = 1) {
        if (dataProvider == nil) {
            loggingPrint("No dataProvider!!!")
            return
        }

        if (loading) {
            refreshControl.endRefreshing()
            return
        }
        
        self.dataProvider!.requestData(page, size: self.dataSize, listener: { json in
            self.unfilteredData.removeAll(keepCapacity: true)
            
            if let next = json["pagination"]["next"].bool {
                if (next == false) {
                    self.end = true
                }
            }

            for (_, obj) in json["data"] {
                self.unfilteredData.append(obj)
            }

            self.setLoadingStatus(false)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let user = appDelegate.user
            self.refilterData(user)
        })
    }

    func refresh(sender: AnyObject) {
        loadData()
    }

    func refilterData(user: UserModel?) {
        let blockedUserIDs = user?.blockedUserIDs ?? Set<Int>()
        
        filteredData = unfilteredData.filter(){ (json: JSON) -> Bool in
            let userID = json["user"]["id"].intValue
            return !blockedUserIDs.contains(userID)
        }
        
        dataProvider?.didfinishLoading(filteredData.count)
        reloadData()
    }
    
    func setLoadingStatus(status: Bool) {
        self.loading = status
        if (!status) {
            self.refreshControl.endRefreshing()
            self.loading = false
        }
    }

    // MARK: -- UITableViewDataSource --

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath)
        let dataTableCell = cell as? DataTableCell
        dataTableCell?.loadData(filteredData[indexPath.row])
        return cell
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: magic number
        return 128.0
    }

    // MARK: -- UITableViewDelegate --

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedClosure?(filteredData[indexPath.row])
    }

    //     MARK: -- Scrolling --

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if (!self.loading && !self.end && (maximumOffset - currentOffset) <= self.spaceToScroll) {
            self.setLoadingStatus(true)
            self.page += 1
            self.loadData(self.page)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canEdit
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            //add code here for when you hit delete
            loggingPrint("will delete")
            self.deletejob(indexPath.row)
        }
    }
    
    func deletejob(row:Int){
        let jobID = filteredData[row]["id"].intValue
        self.dataProvider!.deleteData(jobID) { _ in }
        self.filteredData.removeAtIndex(row)
        if let unfilteredRow = unfilteredRowForJobID(jobID) {
            self.unfilteredData.removeAtIndex(unfilteredRow)
        }
        self.reloadData()
    }
    
    func unfilteredRowForJobID(jobID: Int) -> Int? {
        return unfilteredData.indexOf({(json: JSON) -> Bool in return json["id"].intValue == jobID})
    }
}

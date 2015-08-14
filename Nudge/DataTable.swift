//
//  DataTable.swift
//  Nudge
//
//  Created by Lachezar Todorov on 12.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DataTable: UITableView, UITableViewDataSource, UITableViewDelegate {

    var refreshControl:UIRefreshControl!
    let spaceToScroll:CGFloat = 400
    var cellIdentifier = "NudgeCell"
    var cellNib:String?
    
    var dataSize = 20
    var page = 1
    var end = false
    var loading = false

    var dataProvider:DataProviderProtocol?
    var data:[JSON] = []

    var selectedClosure:((JSON)->())? = nil

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.rowHeight = UITableViewAutomaticDimension

        self.delegate = self
        self.dataSource = self

        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.addSubview(refreshControl)
        self.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleHeight
        self.tableFooterView = UIView(frame: CGRectZero)
    }

    func asignCellNib(name: String) {
        self.cellNib = name
        self.registerNib(UINib(nibName: self.cellNib!, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
    }

    func loadData(page: Int = 1) {

        if (self.dataProvider == nil) {
            println("No dataProvider!!!")
            return
        }

        if (self.loading) {
            self.refreshControl.endRefreshing()
            return
        }

        self.dataProvider!.requestData(page, size: self.dataSize, listener: { json in
            self.data.removeAll(keepCapacity: false)
            
            if let next = json["pagination"]["next"].bool {
                if (next == false) {
                    self.end = true
                }
            }

            for (_, obj) in json["data"] {
                self.data.append(obj)
            }

            self.setLoadingStatus(false)
            
            self.dataProvider!.didfinishLoading(self.data.count)
            self.reloadData()
        })
    }

    func refresh(sender: AnyObject) {
        self.clear()
        self.loadData()
    }

    func setLoadingStatus(status: Bool) {
        self.loading = status

        if (!status) {
            self.refreshControl.endRefreshing()
        }
    }

    // MARK: -- UITableViewDataSource --

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.isEmpty ? 0 : self.data.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:DataTableCell = self.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! DataTableCell
        cell.loadData(self.data[indexPath.row])

        return cell
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 129
    }

    // MARK: -- UITableViewDelegate --

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedClosure?(self.data[indexPath.row])
    }

    func clear()
    {
        if (data.isEmpty) {
            return
        }

        let rowsToDelete: NSMutableArray = []
        for (var i = 0; i < data.count; i++) {
            rowsToDelete.addObject(NSIndexPath(forRow: i, inSection: 0))
        }

        data = []
        page = 1
        end = false

        self.deleteRowsAtIndexPaths(rowsToDelete as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
    }

    //     MARK: -- Scrolling --

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if (!self.loading && !self.end && (maximumOffset - currentOffset) <= self.spaceToScroll) {
            self.setLoadingStatus(true)

            self.page += 1
            self.loadData(page: self.page)
        }
    }


}

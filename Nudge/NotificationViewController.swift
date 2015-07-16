//
//  NotificationViewController.swift
//  Nudge
//
//  Created by Antonio on 03/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationViewController: UITableViewController {

    var data = [Notification]()
    
    let cellIdentifier = "NotificationCell"
    var nextLink:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)

        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)

        loadData()
    }

    func refresh() {
        loadData(append: false, url: nil)
    }

    func loadData(append:Bool = true, url:String? = nil) {

        var defaulUrl = "notifications?params=notification.user,user.image&limit=10"

        API.sharedInstance.get(url == nil ? defaulUrl : url!, closure: {data in

            if !append {
                self.data.removeAll(keepCapacity: false)
            }

            self.nextLink = data["pagination"]["next"].string

            self.populate(data)

        }, errorHandler: {error in
            self.refreshControl?.endRefreshing()
        })
    }

    func loadNext() {
        if (nextLink == nil) {
            return
        }

        loadData(append: true, url: self.nextLink)
    }

    func populate(data:JSON) {

        println("Notifications url request response ->\(data)");

        for (id, obj) in data["data"] {
            self.data.append(Notification.createFromJSON(obj))
        }

        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: -- UITableViewDataSource --
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.data.count
        
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! NotificationCell



        return cell
    }
    
    // MARK: -- UITableViewDelegate --
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

}

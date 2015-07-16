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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)

        API.sharedInstance.get("notifications?params=notification.user,user.image", closure: { response in
            
            println("Notifications url request response ->\(response)");
            
            for (id, obj) in response["data"] {
                let notification = Notification.createFromJSON(obj)
            }
            
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, errorHandler: {error in

        })
    }
    
    // MARK: -- UITableViewDataSource --
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.data.count
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! NotificationCell



        return cell
    }
    
    // MARK: -- UITableViewDelegate --
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

}

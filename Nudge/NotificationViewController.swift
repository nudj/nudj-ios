//
//  NotificationViewController.swift
//  Nudge
//
//  Created by Antonio on 03/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationViewController: BaseController {
    @IBOutlet var notificationTable: UITableView!
    
    var data:[JSON] = []
    
    let cellIdentifier = "NotificationCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationTable.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        self.apiRequest(.GET, path: "notifications", closure: { response in
            
            println("Notifications url request response ->\(response)");
            
            for (id, obj) in response["data"] {
                self.data.append(obj)
            }
            
            self.notificationTable!.reloadData()
        })

    }
    
    // MARK: -- UITableViewDataSource --
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.data.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 70
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = notificationTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! NotificationCell



        
        return cell
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

}

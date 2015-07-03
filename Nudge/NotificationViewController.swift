//
//  NotificationViewController.swift
//  Nudge
//
//  Created by Antonio on 03/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationViewController: BaseController ,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var notificationTable: UITableView!
    
    var data:[JSON] = []
    var indexes:[String] = []
    
    let cellIdentifier = "NotificationCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationTable.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.notificationTable.tableFooterView = UIView(frame: CGRectZero)
        
        self.apiRequest(.GET, path: "notifications?params=notification.user,user.image", closure: { response in
            
            println("Notifications url request response ->\(response)");
            
            for (id, obj) in response["data"] {
                self.indexes.append(id)
                self.data.append(obj)
            }
            
            self.notificationTable!.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: -- UITableViewDataSource --
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.indexes.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 100
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = notificationTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! NotificationCell
        
        if(self.data[indexPath.row]["type"].int == 1){
            cell.buttonConfig(UIColor.greenColor(), withText:"Message")
        }else{
            cell.buttonConfig(UIColor.blueColor(), withText:"Nudge")
        }
        
        cell.descriptionText.text = self.data[indexPath.row]["message"].stringValue
        
        return cell
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    

}

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
    var indexes:[String] = []
    
    let cellIdentifier = "ChatListTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationTable.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.notificationTable.tableFooterView = UIView(frame: CGRectZero)
        
        self.apiRequest(.GET, path: "notifications", closure: { response in
            
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
        
        return 70
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:ChatListTableViewCell = notificationTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! ChatListTableViewCell
        
        var title = self.data[indexPath.row]["job"]["title"]
        cell.jobTitle.text = "re:\(title.stringValue)"
        
        return cell
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var vc:ChatViewController = ChatViewController()
        
        //ChatViewController *chatView  = [ChatViewController messagesViewController];
        //(nibName: "ChatViewController", bundle: nil)
        
        vc.chatID = self.data[indexPath.row]["job"]["id"].stringValue;
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    

}

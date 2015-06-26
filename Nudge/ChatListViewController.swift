//
//  ChatListViewController.swift
//  Nudge
//
//  Created by Antonio on 22/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ChatListViewController: BaseController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var chatTable: UITableView!
    let staticRowHeight:CGFloat = 76
    let cellIdentifier = "ChatListTableViewCell"

    var data:[JSON] = []
    var indexes:[String] = []
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.hidden = true

         self.chatTable.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
         self.chatTable.tableFooterView = UIView(frame: CGRectZero)
        
         self.apiRequest(.GET, path: "chat?params=chat.job,chat.participants,job.title,user.image", closure: { response in
            
            println("Chatroom request response ->\(response)");
        
            for (id, obj) in response["data"] {
                self.indexes.append(id)
                self.data.append(obj)
            }
            
            self.chatTable!.reloadData()
        })
        
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

        var cell:ChatListTableViewCell = chatTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! ChatListTableViewCell
        
        
        var title = self.data[indexPath.row]["job"]["title"]
        cell.jobTitle.text = "re:\(title.stringValue)"
        
        return cell
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var vc:ChatViewController = ChatViewController()
        
        //ChatViewController *chatView  = [ChatViewController messagesViewController];
        //(nibName: "ChatViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    


}
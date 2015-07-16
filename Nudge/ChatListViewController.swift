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
    let staticRowHeight:CGFloat = 70
    let cellIdentifier = "ChatListTableViewCell"

    var data:[JSON] = []
    
    override func viewDidLoad() {

         self.chatTable.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        
        requestData()
        
    }

    func requestData() {
        self.apiRequest(.GET, path: "chat?params=chat.job,job.liked,chat.participants,chat.created,job.title,job.company,job.like,user.image,user.name,user.contact", closure: { response in

            self.data.removeAll(keepCapacity: false)

            for (id, obj) in response["data"] {
                self.data.append(obj)
            }

            self.chatTable.reloadData()
            self.tabBarController?.tabBarItem.badgeValue = "0"
        })
    }
    
    // MARK: -- UITableViewDataSource --
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return staticRowHeight
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell:ChatListTableViewCell = chatTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! ChatListTableViewCell
        
        cell.loadData(self.data[indexPath.row])
        
        return cell
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /*
        
        Example of how to load a viewcontroller from a xib in swift
        ChatViewController *chatView  = [ChatViewController messagesViewController];
        (nibName: "ChatViewController", bundle: nil)
        
        */
        
        // Enter chat room 
        // connect if not already connected
        
        println("Hello")
        
        var conference :String = self.data[indexPath.row]["id"].stringValue
        var appGlobalDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var vc:ChatViewController = ChatViewController()

        let chat = self.data[indexPath.row]

        vc.chatID = chat["id"].stringValue;
        vc.participants = chat["participants"][0]["name"].stringValue + ", you"
        vc.chatTitle = "re: "+chat["job"]["title"].stringValue
        vc.jobID = chat["job"]["id"].stringValue
        vc.userToken = appGlobalDelegate.user?.token
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    


}
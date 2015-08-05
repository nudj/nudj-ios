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

    var data:[ChatStructModel] = []
    
    override func viewDidLoad() {

         self.chatTable.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
         self.chatTable.tableFooterView = UIView(frame: CGRectZero);

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = false
        
        requestData()
        
    }

    func requestData() {
        self.apiRequest(.GET, path: "chat?params=chat.job,job.liked,chat.participants,chat.created,job.title,job.company,job.like,user.image,user.name,user.contact", closure: { response in

            self.data.removeAll(keepCapacity: false)

            for (id, obj) in response["data"] {
                var chat = ChatStructModel()
                self.data.append(chat.createData(obj))
                self.data.sort({ $0.timeinRawForm!.compare($1.timeinRawForm!) == NSComparisonResult.OrderedDescending })
            }
            
            println(response)

            self.chatTable.reloadData()
            self.navigationController?.tabBarItem.badgeValue = nil
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
        
        var cell = tableView.cellForRowAtIndexPath(indexPath)  as! ChatListTableViewCell
        self.data[indexPath.row].markAsRead()
        cell.isRead(self.data[indexPath.row].isRead!)
        
        var chatView:ChatViewController = ChatViewController()
        
        let chat = self.data[indexPath.row]
        chatView.chatID = chat.chatId;
        chatView.participants =  chat.participantName
        chatView.participantsID = chat.participantsID
        chatView.chatTitle = chat.title
        chatView.jobID = chat.jobID
        chatView.otherUserImageUrl = chat.image
            
        self.navigationController?.pushViewController(chatView, animated: true)
                
    }
    


}
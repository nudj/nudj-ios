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
        
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        println("clicked chatroom id \(self.data[indexPath.row].chatId!) -> \(appDelegate.chatInst!.listOfActiveChatRooms[self.data[indexPath.row].chatId!]!.retrieveStoredChats())")
        
        /*
        
        Example of how to load a viewcontroller from a xib in swift
        ChatViewController *chatView  = [ChatViewController messagesViewController];
        (nibName: "ChatViewController", bundle: nil)
        
        */
    
        
        /*var conference :String = self.data[indexPath.row]["id"].stringValue
        var appGlobalDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var vc:ChatViewController = ChatViewController()

        let chat = self.data[indexPath.row]
        let user = chat["participants"][0]["id"].intValue == appGlobalDelegate.user!.id ? chat["participants"][1] : chat["participants"][0]
        
        vc.chatID = chat["id"].stringValue;
        vc.participants =  user["name"].stringValue
        vc.participantsID = user["id"].stringValue
        vc.chatTitle = "re: "+chat["job"]["title"].stringValue
        vc.jobID = chat["job"]["id"].stringValue
        vc.userToken = appGlobalDelegate.user?.token
        vc.selectedIndex = indexPath.row
        vc.otherUserImageUrl = user["image"]["profile"].stringValue
            
        self.navigationController?.pushViewController(vc, animated: true)*/
        
    }
    


}
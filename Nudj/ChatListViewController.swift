//
//  ChatListViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ChatListViewController: BaseController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var chatTable: UITableView!
    let staticRowHeight:CGFloat = 70
    let cellIdentifier = "ChatListTableViewCell"

    @IBOutlet weak var activity: UIActivityIndicatorView!
    var data:[ChatStructModel] = []
    var noContentImage = NoContentPlaceHolder()
    var isArchive: Bool = false
    
    override func viewDidLoad() {
         self.chatTable.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
         self.chatTable.tableFooterView = UIView(frame: CGRectZero);
        
         self.view.addSubview(self.noContentImage.alignInSuperView(self.view, imageTitle: "no_chats"))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MixPanelHandler.sendData("ChatsTabOpened")
        
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = false
        requestData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reload:", name: "reloadChatTable", object: nil);
    }
    
    func deleteChat(){
        // TODO: ?
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reloadChatTable", object: nil)
    }

    func requestData() {
        let path = isArchive ? API.Endpoints.Chat.archived() : API.Endpoints.Chat.active()
        let params = API.Endpoints.Chat.paramsForList(100)
        self.apiRequest(.GET, path: path, params: params, closure: { 
            response in
            self.data.removeAll(keepCapacity: false)
            
            for (_, obj) in response["data"] {
                let chat = ChatStructModel()
                self.data.append(chat.createData(obj))
                self.data.sortInPlace{ $0.timeinRawForm!.compare($1.timeinRawForm!) == NSComparisonResult.OrderedDescending }
            }
            
            self.activity.stopAnimating()
            self.chatTable.hidden = false;
            self.chatTable.reloadData()
            self.chatCounter = 0
            self.navigationController?.tabBarItem.badgeValue = nil
            
            self.noContentImage.hidden = !self.data.isEmpty
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
        let cell:ChatListTableViewCell = chatTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! ChatListTableViewCell
        cell.loadData(self.data[indexPath.row])
        return cell
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)  as! ChatListTableViewCell

        let chatView:ChatViewController = ChatViewController()
        
        let chat = self.data[indexPath.row]
        chatView.chatID = chat.chatId;
        chatView.participants =  chat.participantName
        chatView.participantsID = chat.participantsID
        chatView.chatTitle = chat.title
        chatView.jobID = chat.jobID
        chatView.isLiked = chat.jobLike
        
        if let profileImage = cell.profilePicture.image {
            let imageData = UIImagePNGRepresentation(profileImage)
            let base64String = imageData?.base64EncodedStringWithOptions([]) ?? ""
            chatView.otherUserBase64Image = base64String
        }
        chatView.isArchived = isArchive
            
        self.navigationController?.pushViewController(chatView, animated: true)
        
        self.data[indexPath.row].markAsRead()
        cell.isRead(self.data[indexPath.row].isRead!)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return isArchive ?? false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // TODO: add code here for when you hit delete
            self.deleteChat(indexPath.row)
        }
    }
    
    func deleteChat(row: Int) {
        guard let chatIDStr = data[row].chatId else {return} // TODO: data[row].chatId should be Int not String?
        guard let chatID = Int(chatIDStr) else {return}
        let path = API.Endpoints.Chat.byID(chatID)
        API.sharedInstance.delete(path, params: nil, closure: { 
            response in
            self.data.removeAtIndex(row)
            self.chatTable.reloadData()
        }, errorHandler: { 
            error in
        })
    }
    
    func reload(notification: NSNotification) {
        self.requestData()
    }
}

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
    
    enum Notifications : String {
        case Refetch
    }
   
    @IBOutlet var chatTable: UITableView!
    let staticRowHeight:CGFloat = 70
    let cellIdentifier = "ChatListTableViewCell"

    @IBOutlet weak var activity: UIActivityIndicatorView!
    var unfilteredData = [ChatStructModel]()
    var filteredData = [ChatStructModel]()
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
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector:"reload:", name: Notifications.Refetch.rawValue, object: nil);
        center.addObserver(self, selector:"refilterData:", name: UserModel.Notifications.BlockedUsersChanged.rawValue, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: Notifications.Refetch.rawValue, object: nil)
        center.removeObserver(self, name: UserModel.Notifications.BlockedUsersChanged.rawValue, object: nil)
    }

    func reload(notification: NSNotification) {
        self.requestData()
    }
    
    func refilter(notification: NSNotification) {
        let user = notification.object as? UserModel
        self.refilterData(user)
    }
    
    func requestData() {
        activity.startAnimating()
        let path = isArchive ? API.Endpoints.Chat.archived() : API.Endpoints.Chat.active()
        let params = API.Endpoints.Chat.paramsForList(100)
        apiRequest(.GET, path: path, params: params, closure: { 
            response in
            self.unfilteredData.removeAll(keepCapacity: false)
            
            for (_, obj) in response["data"] {
                let chat = ChatStructModel()
                self.unfilteredData.append(chat.createData(obj))
            }
            self.unfilteredData.sortInPlace{ $0.timeinRawForm!.compare($1.timeinRawForm!) == NSComparisonResult.OrderedDescending }
            self.activity.stopAnimating()
            
            // TODO: remove singleton access
            let user = (UIApplication.sharedApplication().delegate as! AppDelegate).user
            self.refilterData(user)
        })
    }
    
    func refilterData(user: UserModel?) {
        let blockedUserIDs = user?.blockedUserIDs ?? Set<Int>()
        
        filteredData = unfilteredData.filter({ (chat: ChatStructModel) -> Bool in
            guard let userIDStr = chat.participantsID, userID = Int(userIDStr) else {return false}
            return !blockedUserIDs.contains(userID)
        })
        
        chatTable.hidden = false;
        chatTable.reloadData()
        chatCounter = 0
        navigationController?.tabBarItem.badgeValue = nil
        
        noContentImage.hidden = !filteredData.isEmpty
    }
    
    // MARK: -- UITableViewDataSource --
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return staticRowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ChatListTableViewCell = chatTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! ChatListTableViewCell
        cell.loadData(self.filteredData[indexPath.row])
        return cell
    }
    
    // MARK: -- UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)  as! ChatListTableViewCell

        let chatVC = ChatViewController()
        
        let chat = self.filteredData[indexPath.row]
        chatVC.chatID = chat.chatId;
        chatVC.participants =  chat.participantName
        chatVC.participantsID = chat.participantsID
        chatVC.chatTitle = chat.title
        chatVC.jobID = chat.jobID
        chatVC.isLiked = chat.jobLike
        
        if let profileImage = cell.profilePicture.image {
            let imageData = UIImagePNGRepresentation(profileImage)
            let base64String = imageData?.base64EncodedStringWithOptions([]) ?? ""
            chatVC.otherUserBase64Image = base64String
        }
        chatVC.isArchived = isArchive
            
        self.navigationController?.pushViewController(chatVC, animated: true)
        
        self.filteredData[indexPath.row].markAsRead()
        cell.setRead(true)
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
        guard let chatIDStr = filteredData[row].chatId, chatID = Int(chatIDStr) else {return}
        let path = API.Endpoints.Chat.byID(chatID)
        API.sharedInstance.request(.DELETE, path: path, params: nil, closure: { 
            response in
            self.filteredData.removeAtIndex(row)
            if let unfilteredIndex = self.unfilteredRowForChatID(chatID) {
                self.unfilteredData.removeAtIndex(unfilteredIndex)                
            }
            self.chatTable.reloadData()
        }, errorHandler: { 
            error in
        })
    }
    
    func unfilteredRowForChatID(chatID: Int) -> Int? {
        let chatIDStr = String(chatID) // TODO: chat IDs should be Int not String
        return unfilteredData.indexOf({(chat: ChatStructModel) -> Bool in return chat.chatId == chatIDStr})
    }
}

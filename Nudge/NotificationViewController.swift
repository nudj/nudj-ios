//
//  NotificationViewController.swift
//  Nudge
//
//  Created by Antonio on 03/07/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationViewController: UITableViewController, NotificationCellDelegate {

    var data = [Notification]()
    
    let cellIdentifier = "NotificationCell"
    var nextLink:String? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableView.tableFooterView = UIView(frame: CGRectZero);

        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)

        loadData()
    }
    

    func refresh() {
        loadData(append: false, url: nil)
    }

    func loadData(append:Bool = true, url:String? = nil) {

        var defaulUrl = "notifications?params=sender.name,sender.image&limit=10"

        API.sharedInstance.get(url == nil ? defaulUrl : url!, closure: {data in

            if !append {
                self.data.removeAll(keepCapacity: false)
            }

            self.nextLink = data["pagination"]["next"].string

            self.populate(data)

        }, errorHandler: {error in
            self.refreshControl?.endRefreshing()
        })
    }
    
    //, referred by who
    
    func loadNext() {
        if (nextLink == nil) {
            return
        }

        loadData(append: true, url: self.nextLink)
    }

    func populate(data:JSON) {

        println("Notifications url request response ->\(data)");

        for (id, obj) in data["data"] {
            
            if let val = Notification.createFromJSON(obj){
                self.data.append(val)
            }
            
        }

        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: -- UITableViewDataSource --
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.data.count
        
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 120
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! NotificationCell
        
        cell.delegate = self
        cell.setup(self.data[indexPath.row])
        
        
        return cell
    }
    
    // MARK: -- UITableViewDelegate --
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

       //Mark as read
        
    }

    func didPressRightButton(cell:NotificationCell){
        
        if(cell.type == nil){
            
            return;
        }
        
        
        switch cell.type! {
        case .AskToRefer:
            println("Details")
            
            //TODO: USE Segway
            let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var detailsView = storyboard.instantiateViewControllerWithIdentifier("JobDetailedView") as! JobDetailedViewController
            var indexPath:NSIndexPath = tableView.indexPathForCell(cell)!
            detailsView.jobID = self.data[indexPath.row].jobID!
            self.navigationController?.pushViewController(detailsView, animated: true);
            break;
        case .AppApplication:
            println("go to chat")
            /*
            var conference :String = self.data[indexPath.row]["id"].stringValue
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
            
            self.navigationController?.pushViewController(vc, animated: true)*/
            break;
        case .WebApplication:
            println("sms")
            break;
        case .MatchingContact:
            println("Nudge")
            break;
        case .AppApplicationWithNoReferral:
            println("go to chat")
            break;
        case .WebApplicationWithNoReferral:
            println("sms")
            break;
        default:
            break;
        }
        
        
    }
    
    func didPressCallButton(cell: NotificationCell) {
        
        println("Call")

    }
    
    
    func markAsRead(){
    
        // PUT notifications/{id}/read
    }
}

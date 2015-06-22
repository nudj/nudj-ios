//
//  ChatListViewController.swift
//  Nudge
//
//  Created by Antonio on 22/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import Foundation
import UIKit

class ChatListViewController: BaseController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var chatTable: UITableView!
    
    let staticRowHeight:CGFloat = 76
    
    let cellIdentifier = "ChatListTableViewCell"
    
    // MARK: -- UITableViewDataSource --
    
    
    override func viewDidLoad() {
        
         chatTable.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell:UITableViewCell = chatTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        
        cell.textLabel?.text = "hello again"
        
        
        return cell
    }
    
    // MARK: -- UITableViewDelegate --
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("sup?????")
        
        let vc : ChatViewController =  ChatViewController(nibName: "ChatViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

}
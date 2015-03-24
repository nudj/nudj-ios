//
//  ContactsController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 16.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import UIKit

class ContactsController: BaseController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!

    // Hardcoded for performance improvement
    let staticRowHeight:CGFloat = 76

    let cellIdentifier = "ContactsCell"

    var data:[JSON] = []
    var indexes:[String] = []
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        table.registerNib(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        table.rowHeight = self.staticRowHeight
        

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        table.addSubview(refreshControl)

        self.refresh(nil)
    }

    func refresh(sender: AnyObject?) {
        // Load Data
        self.apiRequest(Method.GET, path: "contacts?params=contact.alias,contact.user,user.image,user.status&sizes=user.profile", closure: { response in

            self.indexes = []
            self.data = []

            for (id, obj) in response["data"] {
                self.indexes.append(id)
                self.data.append(obj)
            }

            self.table.reloadData()
            self.refreshControl.endRefreshing()
        })
    }

    // MARK: -- UITableViewDataSource --

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.indexes[section]
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.indexes.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.isEmpty ? 0 : self.data[section].count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ContactsCell = table.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as ContactsCell

        if (self.data[indexPath.section] != nil) {
            cell.loadData(self.data[indexPath.section][indexPath.row])
        } else {
            println("Strange index in contacts table: ", indexPath)
        }

        return cell
    }

    // MARK: -- UITableViewDelegate --

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Selected")
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return self.indexes
    }

}
//
//  ContactsController.swift
//  Nudge
//
//  Created by Lachezar Todorov on 16.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ContactsController: BaseController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!

    // Hardcoded for performance improvement
    let staticRowHeight:CGFloat = 76

    let cellIdentifier = "ContactsCell"

    var indexes = [String]()
    var data = [String:[ContactModel]]()
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

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

        appDelegate.contacts.sync() { success in
            self.loadData()
        }

    }

    func loadData() {
        self.apiRequest(.GET, path: "contacts?params=contact.alias,contact.user,contact.apple_id,user.image,user.status&sizes=user.profile", closure: { response in

            self.data.removeAll(keepCapacity: false)
            self.indexes.removeAll(keepCapacity: false)

            for (id, obj) in response["data"] {
                if self.data[id] == nil {
                    self.indexes.append(id)
                    self.data[id] = [ContactModel]()
                }

                for (index: String, subJson: JSON) in obj {

                    var user:UserModel? = nil
                    if(subJson["user"].type != .Null) {
                        user = UserModel()
                        user!.updateFromJson(subJson["user"])
                    }

                    var contact = ContactModel(id: subJson["id"].intValue, name: subJson["alias"].stringValue, apple_id: subJson["apple_id"].int, user: user)
                    self.data[id]!.append(contact)
                }
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
        if let section = self.data[indexes[section]] {
            return section.count
        }

        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ContactsCell = table.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ContactsCell
        cell.selectable = false

        let index = indexes[indexPath.section]

        if let section = self.data[index] {
            let contact = section[indexPath.row]
            cell.loadData(contact)
        } else {
            println("Strange index in contacts table: ", indexPath)
        }

        return cell
    }

    // MARK: -- UITableViewDelegate --

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactsCell {
            let index = indexes[indexPath.section]

            if let section = self.data[index] {
                let contact = section[indexPath.row]

                if let user = contact.user {
                    //Go to profile view
                    let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var genericController = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController

                    genericController.userId = user.id!
                    genericController.type = .Public
                    genericController.preloadedName = contact.name


                    self.navigationController?.pushViewController(genericController, animated: true)
                }
            }
            
            cell.setSelected(false, animated: true)
        }
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return self.indexes
    }

}
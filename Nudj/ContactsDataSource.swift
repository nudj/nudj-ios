//
//  ContactsDataSource.swift
//  Nudj
//
//  Created by Richard Buckle on 17/03/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

class ContactsDataSource: NSObject, UITableViewDataSource {
    var isSearchEnabled: Bool = false
    
    private let cellIdentifier = "ContactsCell"
    private var filtering = FilterModel()
    private var indexes = [String]()
    private var data = [String:[ContactModel]]()
    
    func registerNib(table: UITableView) {
        table.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func loadData(data: JSON) {
        indexes.removeAll(keepCapacity: true)
        
        let dictionary = data.sort{ $0.0 < $1.0 }
        var content = [ContactModel]()
        
        for (id, obj) in dictionary {
            if self.data[id] == nil {
                self.indexes.append(id)
                self.data[id] = [ContactModel]()
            }
            
            for (_, subJson) in obj {
                var isUser = false
                var user: UserModel? = nil
                var userContact: JSON?
                
                if(subJson["contact"].type != .Null) {
                    user = UserModel()
                    user!.updateFromJson(subJson)
                    
                    userContact = subJson["contact"]
                    isUser = true
                    
                } else if(subJson["user"].type != .Null) {
                    user = UserModel()
                    user!.updateFromJson(subJson["user"])
                }
                
                let userId = isUser ? userContact!["id"].intValue : subJson["id"].intValue
                let name = isUser ? subJson["name"].stringValue : subJson["alias"].stringValue
                let apple_id = isUser ? userContact!["apple_id"].stringValue : subJson["apple_id"].stringValue
                
                // TODO: the server is returning old AB-stype IDs here
                let contact = ContactModel(id: userId, name: name, apple_id: apple_id, user: user)
                self.data[id]!.append(contact)
                content.append(contact)
            }
        }
        
        self.filtering.setContent(content)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isSearchEnabled {
            return nil
        } else {
            return self.indexes[section]
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isSearchEnabled{
            return 1
        }else{
            return self.indexes.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchEnabled {
            return self.filtering.filteredContent.count
        } else {
            if let section = self.data[indexes[section]] {
                return section.count
            }
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ContactsCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ContactsCell
        cell.removeSelectionStyle()
        let contact = contactForIndexPath(indexPath)
        cell.loadData(contact)
        return cell
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.isSearchEnabled ? nil : self.indexes
    }
    
    func contactForIndexPath(indexPath: NSIndexPath) -> ContactModel {
        let contact: ContactModel
        if self.isSearchEnabled {
            contact = self.filtering.filteredContent[indexPath.row]
        } else {
            let index = indexes[indexPath.section]
            
            if let section = self.data[index] {
                contact = section[indexPath.row]
            } else {
                fatalError("Invalid index in contacts table: \(indexPath.debugDescription)")
            }
        }
        return contact
    }
    
    func rowWithAppleIdentifier(appleIdentifier: String) -> Int? {
        // TODO: broken. Rework the data model here.
        if isSearchEnabled {
            return filtering.filteredRowWithIdentifier(appleIdentifier)
        } else {
            return filtering.unfilteredRowWithIdentifier(appleIdentifier)
        }
    }
    
    func startFiltering(filteringText:String, completionHandler:(success:Bool) -> Void) {
        filtering.startFiltering(filteringText, completionHandler: completionHandler)
    }
    
    func stopFiltering() {
        filtering.stopFiltering()
    }
    
    func isEmpty() -> Bool {
        if isSearchEnabled {
            return filtering.filteredContent.isEmpty
        } else {
            return filtering.allContent.isEmpty
        }
    }
}

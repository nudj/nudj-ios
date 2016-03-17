//
//  ContactsDataSource.swift
//  Nudj
//
//  Created by Richard Buckle on 17/03/2016.
//  Copyright © 2016 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

final class ContactsDataSource: NSObject, UITableViewDataSource {
    var isSearchEnabled: Bool = false
    
    private let cellIdentifier = "ContactsCell"
    private var filterModel = FilterModel()
    private var sections = [String]()
    private var contactsBySection = [String:[ContactModel]]()
    private var selectedIDs = Set<Int>()
    
    func registerNib(table: UITableView) {
        table.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func loadData(data newData: JSON) {
        sections.removeAll(keepCapacity: true)
        contactsBySection.removeAll(keepCapacity: true)
        selectedIDs.removeAll()
        
        let sortedData = newData.sort{ $0.0 < $1.0 }
        var allContacts = [ContactModel]()
        
        for (section, contactsJson) in sortedData {
            sections.append(section)
            var contactsForSection = [ContactModel]()
            
            for (_, contactJson) in contactsJson {
                var isUser = false
                var user: UserModel? = nil
                var userContact: JSON?
                
                if contactJson["contact"].type != .Null {
                    user = UserModel()
                    user!.updateFromJson(contactJson)
                    userContact = contactJson["contact"]
                    isUser = true
                } else if contactJson["user"].type != .Null {
                    user = UserModel()
                    user!.updateFromJson(contactJson["user"])
                }
                
                let userId = isUser ? userContact!["id"].intValue : contactJson["id"].intValue
                let name = isUser ? contactJson["name"].stringValue : contactJson["alias"].stringValue
                let apple_id = isUser ? userContact!["apple_id"].stringValue : contactJson["apple_id"].stringValue
                
                // TODO: the server is returning old AB-stype IDs here
                let contact = ContactModel(id: userId, name: name, apple_id: apple_id, user: user)
                contactsForSection.append(contact)
                allContacts.append(contact)
            }
            contactsBySection[section] = contactsForSection
        }
        
        filterModel = FilterModel(content: allContacts)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearchEnabled ? nil : sections[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return isSearchEnabled ? 1 : sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchEnabled {
            return filterModel.filteredContent.count
        } else {
            let section = contactsBySection[sections[section]]
            return section?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ContactsCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ContactsCell
        cell.removeSelectionStyle()
        
        let contact = contactForIndexPath(indexPath)
        cell.loadData(contact)
        
        if selectedIDs.contains(contact.id) {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return isSearchEnabled ? nil : sections
    }
    
    func contactForIndexPath(indexPath: NSIndexPath) -> ContactModel {
        let contact: ContactModel
        if self.isSearchEnabled {
            contact = self.filterModel.filteredContent[indexPath.row]
        } else {
            let index = sections[indexPath.section]
            if let section = self.contactsBySection[index] {
                contact = section[indexPath.row]
            } else {
                fatalError("Invalid index in contacts table: \(indexPath.debugDescription)")
            }
        }
        return contact
    }
    
    func rowWithAppleIdentifier(appleIdentifier: String) -> Int? {
        // TODO: The appleIdentifier thing is broken because neither stable nor globally unique. Rework the data model here.
        if isSearchEnabled {
            return filterModel.filteredRowWithIdentifier(appleIdentifier)
        } else {
            return filterModel.unfilteredRowWithIdentifier(appleIdentifier)
        }
    }
    
    func startFiltering(filteringText:String, completionHandler: () -> Void) {
        let newFilterModel = filterModel.filteredByWordPrefix(filteringText)
        filterModel = newFilterModel
        completionHandler()
    }
    
    func stopFiltering() {
        let newFilterModel = filterModel.unfiltered()
        filterModel = newFilterModel
    }
    
    func isEmpty() -> Bool {
        if isSearchEnabled {
            return filterModel.filteredContent.isEmpty
        } else {
            return filterModel.allContent.isEmpty
        }
    }
    
    func hasSelection() -> Bool {
        return !selectedIDs.isEmpty
    }
    
    func selectedContactIDs() -> [Int] {
        return [Int](selectedIDs)
    }
    
    func isSelected(contactID: Int) -> Bool {
        return selectedIDs.contains(contactID)
    }
    
    func setSelected(contactID: Int, selected: Bool) {
        if selected {
            selectedIDs.insert(contactID)
        } else {
            selectedIDs.remove(contactID)
        }
    }
    
    /// Complexity O(n)
    func contactWithID(contactID: Int) -> ContactModel? {
        return filterModel.contactWithID(contactID)
    }
    
}

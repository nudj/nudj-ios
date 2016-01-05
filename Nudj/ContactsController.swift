//
//  ContactsController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct ContactPaths {
    static let all = "contacts/mine"
    static let favourites = "users/me/favourites"
}

class ContactsController: BaseController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var activityIndi: UIActivityIndicatorView!
    var searchBar =  UISearchBar()
    var isSearchEnabled:Bool = false
    
    // Hardcoded for performance improvement
    let staticRowHeight:CGFloat = 76

    let cellIdentifier = "ContactsCell"

    var filtering = FilterModel()
    var indexes = [String]()
    var data = [String:[ContactModel]]()
    var refreshControl:UIRefreshControl!
    var lastSelectedContact:ContactModel?
    var noContentImage = NoContentPlaceHolder()
    
    override func viewDidLoad() {
        
        self.searchBar.hidden = true
        self.searchBar.delegate = self;
        self.searchBar.searchBarStyle = UISearchBarStyle.Default
        self.searchBar.showsCancelButton = true
        self.searchBar.showsScopeBar = true
        self.searchBar.frame = CGRectMake(0, 0, self.view.frame.width, 70)
        self.view.addSubview(self.searchBar)
        
        table.registerNib(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        table.rowHeight = self.staticRowHeight
        
        table.backgroundColor = UIColor.whiteColor()
        table.tableFooterView = UIView(frame: CGRectZero)

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: Localizations.General.PullToRefresh)
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        table.addSubview(refreshControl)

        self.refresh()
        
        self.activityIndi.hidden = false
        self.table.hidden = true
        
        self.view.addSubview(self.noContentImage.alignInSuperView(self.view, imageTitle: "no_contacts"))
    }

    override func viewWillAppear(animated: Bool) {
        MixPanelHandler.sendData("ContactsTabOpened")
        
        if isSearchEnabled {
            self.navigationController?.navigationBarHidden = true;
        }
        
        if(self.segControl.selectedSegmentIndex == 1 ){
            self.table.hidden = true;
            self.activityIndi.hidden = false
            self.loadData(self.getContactsUrl())
        }
            
        self.tabBarController?.tabBar.hidden = false
    }

    func refresh(sender: AnyObject?) {
        refresh()
    }

    func refresh() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

        appDelegate.contacts.sync() { success in
            self.loadData(self.getContactsUrl())
        }
    }

    func loadData(url:String) {
        // API strings
        let variable = url == ContactPaths.all ? "contact.user" : "user.contact"
        let path = "\(url)?params=\(variable),contact.alias,contact.apple_id,user.image,user.status,user.name&sizes=user.profile"

        self.apiRequest(.GET, path: path, closure: { response in
            self.data.removeAll(keepCapacity: false)
            self.indexes.removeAll(keepCapacity: false)

            let dictionary = response["data"].sort{ $0.0 < $1.0 }
            var content = [ContactModel?]();
            
            for (id, obj) in dictionary {
                if self.data[id] == nil {
                    self.indexes.append(id)
                    self.data[id] = [ContactModel]()
                }

                for (_, subJson) in obj {
                    var isUser = false
                    var user:UserModel? = nil
                    var userContact:JSON?

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
                    let apple_id = isUser ? userContact!["apple_id"].int : subJson["apple_id"].int

                    let contact = ContactModel(id: userId, name: name, apple_id: apple_id, user: user)
                    self.data[id]!.append(contact)
                    content.append(contact)
                }
            }
            
            self.filtering.setContent(content)
            self.table.reloadData()
            self.refreshControl.endRefreshing()
            
            self.activityIndi.hidden = true
            self.table.hidden = false
            
            if(self.filtering.filteredContent.count == 0){
                self.noContentImage.hidden = false
            }else{
                self.noContentImage.hidden = true
            }
        })
    }

    // MARK: -- UITableViewDataSource --

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isSearchEnabled{
            return nil
        }else{
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
        if self.isSearchEnabled{
            return self.filtering.filteredContent.count
        }else{
            if let section = self.data[indexes[section]] {
                return section.count
            }
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ContactsCell = table.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ContactsCell
        cell.removeSelectionStyle()
        if(self.isSearchEnabled == true){
            if let contact = self.filtering.filteredContent[indexPath.row] {
                cell.loadData(contact)
            }
        }else{
            let index = indexes[indexPath.section]

            if let section = self.data[index] {
                let contact = section[indexPath.row]
                cell.loadData(contact)
            } else {
                loggingPrint("Strange index in contacts table: ", indexPath.debugDescription)
            }
        }
        return cell
    }

    // MARK: -- UITableViewDelegate --

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactsCell {
            let index = indexes[indexPath.section]
        
            if let section = self.data[index] {
                guard let contact = self.isSearchEnabled ? self.filtering.filteredContent[indexPath.row] : section[indexPath.row] else {
                    return
                }
                
                if let user = contact.user {
                    //Go to profile view
                    let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let genericController = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController
                    genericController.userId = user.id!
                    genericController.type = .Public
                    genericController.preloadedName = contact.name

                    self.navigationController?.pushViewController(genericController, animated: true)
                } else {
                    lastSelectedContact = contact
                    let message = Localizations.Invitation.Send.Body.Format(contact.name)
                    let alert = UIAlertController.init(title: Localizations.Invitation.Send.Title, message: message, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction.init(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    let inviteAction = UIAlertAction.init(title: Localizations.Invitation.Send.Button, style: .Default, handler: inviteUser)
                    alert.addAction(inviteAction)
                    alert.preferredAction = inviteAction
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            cell.setSelected(false, animated: true)
        }
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.isSearchEnabled ? nil : self.indexes
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if self.isSearchEnabled == false {
            view.tintColor = UIColor.whiteColor()
        }
    }
    
    func inviteUser(_: UIAlertAction) {
        MixPanelHandler.sendData("InviteUserAction")
        guard let contactName = lastSelectedContact?.name else {
            return
        }
        guard let contactID = lastSelectedContact?.id else {
            return
        }
        API.sharedInstance.post("contacts/\(contactID)/invite", params: nil, 
            closure: { 
                result in
                let title: String
                let message: String
                if (result["status"].boolValue) {
                    title = Localizations.Invitation.Successful.Title
                    message = Localizations.Invitation.Successful.Body.Format(contactName)
                } else {
                    title = Localizations.Invitation.Failed.Title
                    message = Localizations.Invitation.Failed.Body.Format(contactName)
                }
                let alert = UIAlertController.init(title: title, message: message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction.init(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                alert.preferredAction = cancelAction
                self.presentViewController(alert, animated: true, completion: nil)
            },
            errorHandler: { 
                error in
                let title = Localizations.Invitation.Failed.Title
                let message = Localizations.Invitation.Failed.Body.Format(contactName)
                let alert = UIAlertController.init(title: title, message: message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction.init(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                alert.preferredAction = cancelAction
                self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func segmentSelection(sender: UISegmentedControl) {
        self.table.hidden = true;
        self.activityIndi.hidden = false
        self.loadData(getContactsUrl())
    }

    func getContactsUrl() -> String {
        self.noContentImage.image = segControl.selectedSegmentIndex <= 0 ? UIImage(named:"no_contacts") : UIImage(named:"no_favourite_contacts")
        return segControl.selectedSegmentIndex <= 0 ? ContactPaths.all : ContactPaths.favourites
    }
    
    @IBAction func searchButton(sender: UIBarButtonItem) {
        self.navigationController?.navigationBarHidden = true;
        segControl.hidden = true
        self.searchBar.hidden = false
        self.searchBar.becomeFirstResponder()
        self.isSearchEnabled = true
    }
    
    //MARK: Searcbar
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if(searchBar.text?.isEmpty ?? true){
            searchBar.resignFirstResponder()
            self.searchBar.hidden = true
            segControl.hidden = false
            self.navigationController?.navigationBarHidden = false;
            self.isSearchEnabled = false
        } else {
            self.filtering.stopFiltering()
            searchBar.text = ""
            self.table.reloadData()
        }
    }
    
    func searchBar(searchBar :UISearchBar, textDidChange searchText:String){
        if(!searchText.isEmpty){
            self.filtering.startFiltering(searchText, completionHandler: { (success) -> Void in
                self.table.reloadData()
            })
        } else {
            self.filtering.stopFiltering()
            self.table.reloadData()
        }
    }
}

//
//  ContactsController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

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
    
    deinit {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: Contacts.Notification.ContactThumbnailReceived.rawValue, object: nil)
    }
    
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

        self.refresh(self)
        
        self.activityIndi.hidden = false
        self.table.hidden = true
        
        self.view.addSubview(self.noContentImage.alignInSuperView(self.view, imageTitle: "no_contacts"))
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: Selector("contactThumbnailReceived:"), name: Contacts.Notification.ContactThumbnailReceived.rawValue, object: nil)
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

    @IBAction func refresh(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

        appDelegate.contacts.sync() { success in
            self.loadData(self.getContactsUrl())
        }
    }
    
    func contactThumbnailReceived(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let identifier = userInfo[Contacts.ThumbnailKey.Identifier.rawValue] as? String else {return}
        guard let image = userInfo[Contacts.ThumbnailKey.Image.rawValue] as? UIImage else {return}
        
        self.applyThumbnail(thumbnail: image, toContactIdentifier: identifier)
    }
    
    func applyThumbnail(thumbnail thumbnail: UIImage, toContactIdentifier identifier: String) {
        // TODO: broken. Rework the data model here.
        guard let row = filtering.filteredRowWithIdentifier(identifier) else {return}
        let cell = self.table.cellForRowAtIndexPath(NSIndexPath(index: row)) as? ContactsCell
        cell?.profileImage.setCustomImage(thumbnail)
        cell?.setNeedsDisplay()
    }

    func loadData(path: String) {
        // TODO: this network access is slowing down the UI: fix it
        // API strings
        let fields = (path == API.Endpoints.Contacts.mine) ? ["contact.user"] : ["user.contact"]
        let params = API.Endpoints.Contacts.paramsForList(fields)

        self.apiRequest(.GET, path: path, params: params, closure: { response in
            self.data.removeAll(keepCapacity: false)
            self.indexes.removeAll(keepCapacity: false)

            let dictionary = response["data"].sort{ $0.0 < $1.0 }
            var content = [ContactModel]();
            
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
                    let apple_id = isUser ? userContact!["apple_id"].stringValue : subJson["apple_id"].stringValue

                    // TODO: the server is returning old AB-stype IDs here
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
            let contact = self.filtering.filteredContent[indexPath.row]
            cell.loadData(contact)
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
                let contact = self.isSearchEnabled ? self.filtering.filteredContent[indexPath.row] : section[indexPath.row]
                
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
                    let alert = UIAlertController(title: Localizations.Invitation.Send.Title, message: message, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    let inviteAction = UIAlertAction(title: Localizations.Invitation.Send.Button, style: .Default, handler: inviteUser)
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
        let path = API.Endpoints.Contacts.inviteByID(contactID)
        API.sharedInstance.post(path, params: nil, 
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
                let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                alert.preferredAction = cancelAction
                self.presentViewController(alert, animated: true, completion: nil)
            },
            errorHandler: { 
                error in
                let title = Localizations.Invitation.Failed.Title
                let message = Localizations.Invitation.Failed.Body.Format(contactName)
                let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
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
        let wantFavorites = segControl.selectedSegmentIndex > 0
        let noContentImageName = wantFavorites ? "no_favourite_contacts" : "no_contacts"
        self.noContentImage.image = UIImage(named:noContentImageName)
        return wantFavorites ? API.Endpoints.Users.favouriteByID(0) : API.Endpoints.Contacts.mine
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

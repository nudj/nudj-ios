//
//  ContactsController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

class ContactsController: BaseController, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var activityIndi: UIActivityIndicatorView!
    let dataSource = ContactsDataSource()
    var searchBar =  UISearchBar()
    var refreshControl:UIRefreshControl!
    var lastSelectedContact:ContactModel?
    var noContentImage = NoContentPlaceHolder()
    
    deinit {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: Contacts.Notification.ContactThumbnailReceived.rawValue, object: nil)
    }
    
    override func viewDidLoad() {
        
        self.searchBar.hidden = true
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = UISearchBarStyle.Default
        self.searchBar.showsCancelButton = true
        self.searchBar.showsScopeBar = true
        self.searchBar.frame = CGRectMake(0, 0, self.view.frame.width, 70)
        self.view.addSubview(self.searchBar)
        
        dataSource.registerNib(table)
        table.dataSource = dataSource
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
        
        if dataSource.isSearchEnabled {
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
        guard let row = dataSource.rowWithAppleIdentifier(identifier) else {return}
        let cell = self.table.cellForRowAtIndexPath(NSIndexPath(index: row)) as? ContactsCell
        cell?.profileImage.setCustomImage(thumbnail)
        cell?.setNeedsDisplay()
    }

    func loadData(path: String) {
        // TODO: this network access is slowing down the UI: fix it
        // API strings
        let fields = (path == API.Endpoints.Contacts.mine) ? ["contact.user"] : ["user.contact"]
        let params = API.Endpoints.Contacts.paramsForList(fields)

        self.apiRequest(.GET, path: path, params: params, closure: { 
            response in
            self.dataSource.loadData(data: response["data"])
            self.table.reloadData()
            self.refreshControl.endRefreshing()
            
            self.activityIndi.hidden = true
            self.table.hidden = false
            
            self.noContentImage.hidden = !self.dataSource.isEmpty()
        })
    }

    // MARK: -- UITableViewDelegate --

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactsCell else {return}
        let contact = dataSource.contactForIndexPath(indexPath)
        
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
        
        cell.setSelected(false, animated: true)
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
        API.sharedInstance.request(.POST, path: path, params: nil, 
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
        dataSource.isSearchEnabled = true
    }
    
    //MARK: Searcbar
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dataSource.isSearchEnabled = false
        if searchBar.text?.isEmpty ?? true {
            searchBar.resignFirstResponder()
            self.searchBar.hidden = true
            segControl.hidden = false
            self.navigationController?.navigationBarHidden = false
        } else {
            dataSource.stopFiltering()
            searchBar.text = ""
        }
        self.table.reloadData()
    }
    
    func searchBar(searchBar :UISearchBar, textDidChange searchText:String){
        if(!searchText.isEmpty){
            dataSource.startFiltering(searchText, completionHandler: { (success) -> Void in
                self.table.reloadData()
            })
        } else {
            dataSource.stopFiltering()
            table.reloadData()
        }
    }
}

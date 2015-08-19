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

struct ContactPaths {
    static let all = "contacts/mine"
    static let favourites = "users/me/favourites"
}

class ContactsController: BaseController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var activityIndi: UIActivityIndicatorView!
    var alert = UIAlertView()
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
        
        
        //Invite pop up config
        self.alert  = UIAlertView(title: "Invite", message: "", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
        
        table.registerNib(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        table.rowHeight = self.staticRowHeight
        
        table.backgroundColor = UIColor.whiteColor()
        table.tableFooterView = UIView(frame: CGRectZero)

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        table.addSubview(refreshControl)

        self.refresh()
        
        self.activityIndi.hidden = false
        self.table.hidden = true
        
        self.view.addSubview(self.noContentImage.createNoContentPlaceHolder(self.view, imageTitle: "no_contacts"))
    }

    override func viewWillAppear(animated: Bool) {
        
        if isSearchEnabled == true {
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

        let variable = url == ContactPaths.all ? "contact.user" : "user.contact"
        let path = "\(url)?params=\(variable),contact.alias,contact.apple_id,user.image,user.status,user.name&sizes=user.profile"

        self.apiRequest(.GET, path: path, closure: { response in
            println(response)

            self.data.removeAll(keepCapacity: false)
            self.indexes.removeAll(keepCapacity: false)

            let dictionary = sorted(response["data"]) { $0.0 < $1.0 }
            var content = [ContactModel?]();
            
            for (id, obj) in dictionary {
                if self.data[id] == nil {
                    self.indexes.append(id)
                    self.data[id] = [ContactModel]()
                }

                for (index: String, subJson: JSON) in obj {

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

                    var contact = ContactModel(id: userId, name: name, apple_id: apple_id, user: user)
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
                
                self.noContentImage.showPlaceholder()
                
            }else{
                
                self.noContentImage.hidePlaceholder()
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
                println("Strange index in contacts table: ", indexPath)
            }
            
        }
        return cell
    }

    // MARK: -- UITableViewDelegate --

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactsCell {
            let index = indexes[indexPath.section]
        
            if let section = self.data[index] {
                
                var contact :ContactModel?
                
                if self.isSearchEnabled == true {
                    contact = self.filtering.filteredContent[indexPath.row]
                }else{
                    contact = section[indexPath.row]
                }
                
                if let user = contact?.user {
                    //Go to profile view
                    let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var genericController = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController

                    genericController.userId = user.id!
                    genericController.type = .Public
                    genericController.preloadedName = contact!.name


                    self.navigationController?.pushViewController(genericController, animated: true)
                    
                }else{

                    lastSelectedContact = contact
                    self.alert.message = "Would you like to tell \(contact!.name) about Nudge?";
                    self.alert.show();
                }
            }
            
            cell.setSelected(false, animated: true)
        }
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
       if self.isSearchEnabled == true {
        
        return nil
        
       }else{
       
        return self.indexes
        
        }
    }

    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if self.isSearchEnabled == false {
        view.tintColor = UIColor.whiteColor()
        }
    }
    
    
    
    //MARK :Invite user
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0{
            
            println("Dissmiss pop up")
            
        }else{
            
            var alertview  = UIAlertView(title: "Invite", message: "", delegate: self, cancelButtonTitle: "OK")
            
            
            API.sharedInstance.post("contacts/\(lastSelectedContact!.id)/invite", params: nil, closure: { result in
            
                if (result["status"].boolValue) {
                    alertview.title = "Invite Successful"
                    alertview.message = "Contact has been invited";
                } else {
                    alertview.title = "Invite Failed"
                    alertview.message = "There was a problem inviting your friend";
                }

                
            },errorHandler: { error in
                
                    alertview.title = "Invite Failed"
                    alertview.message = "There was a problem inviting your friend";
                    
            })
            
            alertview.show();
            
        }
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
        
            if(searchBar.text == ""){
                
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
                
            }else {
                
                self.filtering.stopFiltering()
                self.table.reloadData()
            }
            
        }
        
    
}
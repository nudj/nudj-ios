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

    var filtering:FilterModel?
    var indexes = [String]()
    var data = [String:[ContactModel]]()
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        
        self.searchBar.hidden = true
        self.searchBar.delegate = self;
        self.searchBar.searchBarStyle = UISearchBarStyle.Default
        self.searchBar.showsCancelButton = true
        self.searchBar.showsScopeBar = true
        self.searchBar.frame = CGRectMake(0, 20, self.view.frame.width, 50)
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

        self.refresh(nil)
        
        self.activityIndi.hidden = false
        self.table.hidden = true
    }

    override func viewWillAppear(animated: Bool) {
        
        if isSearchEnabled == true {
            
            self.navigationController?.navigationBarHidden = true;
            
        }
    }
    
    func refresh(sender: AnyObject?) {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

        appDelegate.contacts.sync() { success in
            self.loadData("contacts/mine")
        }

    }

    func loadData(url:String!) {

        self.apiRequest(.GET, path: "\(url!)?params=contact.alias,contact.user,contact.apple_id,user.image,user.status&sizes=user.profile", closure: { response in

            self.data.removeAll(keepCapacity: false)
            self.indexes.removeAll(keepCapacity: false)

            let dictionary = sorted(response["data"]) { $0.0 < $1.0 }
            var content:[ContactModel] = [];
            
            for (id, obj) in dictionary {
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
                    content.append(contact)
                }
            }
            
            self.filtering = FilterModel(content:content)
            self.table.reloadData()
            self.refreshControl.endRefreshing()
            
            self.activityIndi.hidden = true
            self.table.hidden = false
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
            
            return self.filtering!.filteredContent.count
            
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
            
             cell.loadData(self.filtering!.filteredContent[indexPath.row] as ContactModel)
            
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
                    contact = self.filtering!.filteredContent[indexPath.row]
                }else{
                    contact = section[indexPath.row]
                }
                
                if let user = contact!.user {
                    //Go to profile view
                    let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var genericController = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController

                    genericController.userId = user.id!
                    genericController.type = .Public
                    genericController.preloadedName = contact!.name


                    self.navigationController?.pushViewController(genericController, animated: true)
                    
                }else{
                    
                    self.alert.message = "Do you want to invite \(contact!.name)?";
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
            
            println("send sms")
        }
    }
    
    
    @IBAction func segmentSelection(sender: UISegmentedControl) {
        
        self.table.hidden = true;
        self.activityIndi.hidden = false
        
        if segControl.selectedSegmentIndex == 0{
            
            self.loadData("contacts/mine")
        }
        
        if segControl.selectedSegmentIndex == 1{
        
            self.loadData("contacts/favourited")
        }
    }
    
    @IBAction func searchButton(sender: UIBarButtonItem) {
        
        self.navigationController?.navigationBarHidden = true;
        self.searchBar.hidden = false
        self.searchBar.becomeFirstResponder()
        self.isSearchEnabled = true
    }
    
    
    //MARK: Searcbar
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
            if(searchBar.text == ""){
                
                searchBar.resignFirstResponder()
                self.searchBar.hidden = true
                self.navigationController?.navigationBarHidden = false;
                self.isSearchEnabled = false
                
            }else{
                
                self.filtering?.stopFiltering()
                searchBar.text = ""
                self.table.reloadData()
                
            }
       
        
    }
    
    func searchBar(searchBar :UISearchBar, textDidChange searchText:String){
        
            
            if(!searchText.isEmpty){
                
                self.filtering!.startFiltering(searchText, completionHandler: { (success) -> Void in
                    self.table.reloadData()
                })
                
            }else {
                
                self.filtering!.stopFiltering()
                self.table.reloadData()
            }
            
        }
        
    
}
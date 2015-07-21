//
//  AskReferralViewController.swift
//  Nudge
//
//  Created by Antonio on 30/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class AskReferralViewController: UIViewController, UISearchBarDelegate ,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CreatePopupViewDelegate{
    
    @IBOutlet var askTable: UITableView!
    @IBOutlet var searchBarView: UISearchBar!
    @IBOutlet weak var messageText: UITextView!

    var jobId:Int?
    
    var searchActive : Bool = false
    var data:[String] = []
    var filtered:[String] = []

    var currentContent:[ContactModel] = [];
    var searchResult:[ContactModel]  = [];
    var selected = [ContactModel]()
    var popup :CreatePopupView?;
    
    let cellIdentifier = "ContactsCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.hidden = true

        // Do any additional setup after loading the view.
        
        askTable.registerNib(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)

        self.loadData()
    }

    func loadData() {
        ContactModel.getContacts { status, response in
            if (!status) {
                return
            }

            for (id, parentObj) in response["data"] {
                for (id, obj) in parentObj {

                    var user:UserModel? = nil

                    if(obj["user"].type != .Null) {
                        user = UserModel()
                        user!.updateFromJson(obj["user"])
                    }

                    var contact = ContactModel(id: obj["id"].intValue, name: obj["alias"].stringValue, apple_id: obj["apple_id"].int, user: user)
                    self.data.append(obj["alias"].stringValue)
                    self.currentContent.append(contact)
                }
            }

            self.searchResult = self.currentContent
            self.askTable.reloadData()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.tabBarController?.tabBar.hidden = false
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        self.askTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        self.askTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        self.askTable.reloadData()
    }

    
    func searchBar(searchBar :UISearchBar, textDidChange searchText:String){
        
        searchBar.showsCancelButton = true;
        
        if(!searchText.isEmpty){
            filtered = data.filter({ (text) -> Bool in
                let tmp: NSString = text
                let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            })
            if(filtered.count == 0){
                searchActive = false;
            } else {
                searchActive = true;
            }
            self.askTable.reloadData()

        }

    }
    


    // MARK: -- UITableViewDataSource --
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if(searchActive) {
            return filtered.count
        }

        return self.searchResult.count;
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 76;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:ContactsCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ContactsCell
        
        /*cell.loadData(self.searchResult.objectAtIndex(indexPath.row) as! ContactModel)

        return cell*/
        
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
            cell.textLabel?.text = data[indexPath.row];
        }
        
        return cell;
    }
    
    // MARK: -- UITableViewDelegate --
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactsCell {
            if let contact = searchResult[indexPath.row] as? ContactModel {

                // TODO: Fix this!!!
                for (index, value) in enumerate(selected) {
                    if value.id == contact.id {
                        selected.removeAtIndex(index)
                        cell.setSelected(false, animated: true)
                        checkSelected()
                        return
                    }
                }

                selected.append(contact)
                cell.setSelected(true, animated: true)
                checkSelected()
            }
        }

    }

    func checkSelected() {
        self.navigationItem.rightBarButtonItem?.enabled = (selected.count > 0)
    }

    @IBAction func askAction(sender: AnyObject) {

        let contactIds:[Int] = selected.map { contact in
            return contact.id
        }

        let params:[String:AnyObject] = ["job": "\(jobId!)", "contacts": contactIds, "message": messageText.text]

        println("AskForReferal: \(params)")

        API.sharedInstance.put("nudge/ask", params: params, closure: { result in

            self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
            self.popup!.bodyText("You have successfully asked \(contactIds.count) contacts for referral");
            self.popup!.delegate = self;
            self.view.addSubview(self.popup!);

            println(result)
        }) { error in
            println(error)
        }

    }

    @IBAction func close(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func dismissPopUp() {
        
        popup!.removeFromSuperview();
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
        
}

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
    @IBOutlet weak var messageLabel: UILabel!

    var jobId:Int?
    var isNudjRequest:Bool?
    
    var filtering:FilterModel?
    
    var selected = [ContactModel]()
    var popup :CreatePopupView?;
    
    let cellIdentifier = "ContactsCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.hidden = true
        
        if(self.isNudjRequest!){
            self.title = "Refer Someone"
            self.messageLabel.text = "Select the contacts that you would like to refer"
        }
        
        askTable.registerNib(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        
        self.loadData()
    }

    func loadData() {
        ContactModel.getContacts { status, response in
            if (!status) {
                return
            }

            let dictionary = sorted(response["data"]) { $0.0 < $1.0 }
            var content:[ContactModel] = [];
            
            for (id, parentObj) in dictionary {
                for (id, obj) in parentObj {

                    var user:UserModel? = nil

                    if(obj["user"].type != .Null) {
                        user = UserModel()
                        user!.updateFromJson(obj["user"])
                    }

                    var contact = ContactModel(id: obj["id"].intValue, name: obj["alias"].stringValue, apple_id: obj["apple_id"].int, user: user)
                    content.append(contact)
                }
            }
            
            self.filtering = FilterModel(content: content)
            self.askTable.reloadData()
        }
    }

    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = true
    }
    
    //MARK: TextView Delegate
    func textViewDidBeginEditing(textView: UITextView) {
        
        if(textView.text == "Enter your personalised message"){
            textView.text = ""
        }
        
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    
    //MARK: Search bar Delegates
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //searchActive = true;
        /* if(self.filtering != nil && searchBar.text.isEmpty){
            self.filtering?.stopFiltering()
        }*/
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        //searchActive = false;
        //self.askTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if(self.filtering != nil){
            if(searchBar.text == ""){
                searchBar.resignFirstResponder()
            }else{
                self.filtering?.stopFiltering()
                searchBar.text = ""
                self.askTable.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
       
        searchBar.resignFirstResponder()
    }

    
    func searchBar(searchBar :UISearchBar, textDidChange searchText:String){
        
        searchBar.showsCancelButton = true;
        
        if(self.filtering != nil){
        
            if(!searchText.isEmpty){
                
                self.filtering!.startFiltering(searchText, completionHandler: { (success) -> Void in
                    self.askTable.reloadData()
                })
                
            }else {
                
                self.filtering!.stopFiltering()
                self.askTable.reloadData()
            }
        
        }

    }
    


    // MARK: -- UITableViewDataSource --
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.filtering != nil ? self.filtering!.filteredContent.count : 0
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 76;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: ContactsCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? ContactsCell
        
        if cell == nil {
            tableView.registerNib(UINib(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
            cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? ContactsCell
        }
        
        if(self.filtering != nil){
            var contact = self.filtering!.filteredContent[indexPath.row] as ContactModel
            cell!.loadData(contact)
            
            if selected.count > 0 {
                
                //TODO: Find a better way
                for (index, value) in enumerate(selected) {
                    if value.id == contact.id {
                        cell!.selected = true
                    }
                }
                

            }
            
            
        }
        
        return cell!
        
    }
    
    // MARK: -- UITableViewDelegate --
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactsCell {
            //TODO: Change search results to array of Optionals
            if let contact = self.filtering!.filteredContent[indexPath.row] as? ContactModel {

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
            
            checkSelected()
            
        }

    }

    func checkSelected() {
        self.navigationItem.rightBarButtonItem?.enabled = (selected.count > 0)
    }

    @IBAction func askAction(sender: AnyObject) {
        
        self.resignFirstResponder()
        self.view.endEditing(true)
        
        
        let contactIds:[Int] = selected.map { contact in
            return contact.id
        }

        let params:[String:AnyObject] = ["job": "\(jobId!)", "contacts": contactIds, "message": messageText.text]
        self.messageText.resignFirstResponder()

        if(self.isNudjRequest!){
            
             println("nudge: \(params)")
            
            API.sharedInstance.put("nudge", params: params, closure: { result in
            
            self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
            self.popup!.bodyText("You have successfully nudged  \(contactIds.count) user");
            self.popup!.delegate = self;
            self.view.addSubview(self.popup!);
            
            println(result)
            }) { error in
                println(error)
            }
            
        }else{
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

    }
    

    @IBAction func close(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func dismissPopUp() {
        
        popup!.removeFromSuperview();
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
        
}

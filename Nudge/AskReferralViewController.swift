//
//  AskReferralViewController.swift
//  Nudge
//
//  Created by Antonio on 30/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit

class AskReferralViewController: UIViewController, UISearchBarDelegate ,UITableViewDataSource, UITableViewDelegate, CreatePopupViewDelegate{
    
    @IBOutlet var askTable: UITableView!
    @IBOutlet var messageText: UITextField!
    @IBOutlet var searchBarView: UISearchBar!

    var jobId:Int?

    var currentContent = NSMutableArray();
    var searchResult = NSMutableArray();
    var selected = [ContactModel]()
    var popup :CreatePopupView?;
    
    let cellIdentifier = "ContactsCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.hidden = true

        self.messageText.frame = CGRectMake(0, 0, messageText.frame.size.width, messageText.frame.size.height);
        // Do any additional setup after loading the view.
        
        askTable.registerNib(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)

        self.loadData()
    }

    func loadData() {
        ContactModel.getContacts { status, response in
            if (!status) {
                return
            }

            self.currentContent.removeAllObjects()
            self.searchResult.removeAllObjects()

            for (id, parentObj) in response["data"] {
                for (id, obj) in parentObj {

                    var user:UserModel? = nil

                    if(obj["user"].type != .Null) {
                        user = UserModel()
                        user!.updateFromJson(obj["user"])
                    }

                    var contact = ContactModel(id: obj["id"].intValue, name: obj["alias"].stringValue, apple_id: obj["apple_id"].int, user: user)
                    self.currentContent.addObject(contact)
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
    
    
    func searchBar(searchBar :UISearchBar, textDidChange searchText:String){
        
        searchBar.showsCancelButton = true;
        
        if(!searchText.isEmpty){
            println("updated search");
                
            self.updateFilteredContentForProductName(searchText);
            self.askTable.reloadData();

        }

    }
    
    
    func updateSearchResultsForSearchController(searchController :UISearchBar){
    
        println("Testing typing")
        
        var searchString :String = searchController.text;
        self.updateFilteredContentForProductName(searchString);
    
    }
    
    
    //Mark - Content Filtering

    func updateFilteredContentForProductName(productName :String){
    
        self.searchResult.removeAllObjects(); // First clear the filtered array.
    
        /*  
        
        Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
        
        */
        
        var product: ReferralFilterContent?
        
        for product in self.currentContent {
            
            println("what products see -> \(product.name)")
            
            var searchOptions = NSStringCompareOptions.CaseInsensitiveSearch | NSStringCompareOptions.DiacriticInsensitiveSearch;
            var productNameRang = Range<String.Index>(start: productName.startIndex, end: productName.endIndex);
            var foundRange =  product.name.substringWithRange(productNameRang) as  String;
            
            if (foundRange == productName) {
                self.searchResult.addObject(product);
            }
        
        }
        
    }

    // MARK: -- UITableViewDataSource --
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.searchResult.count;
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 76;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:ContactsCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ContactsCell
        
        cell.loadData(self.searchResult.objectAtIndex(indexPath.row) as! ContactModel)

        return cell
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

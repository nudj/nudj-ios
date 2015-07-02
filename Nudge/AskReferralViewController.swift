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
    
    var currentContent :NSMutableArray?;
    var searchResult :NSMutableArray?;
    var indexes :NSArray?;
    var isSearchTable :Bool = false
    var popup :CreatePopupView?;
    
    let cellIdentifier = "ContactsCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageText.frame = CGRectMake(0, 0, messageText.frame.size.width, messageText.frame.size.height);
        // Do any additional setup after loading the view.
        
        currentContent = NSMutableArray();
        searchResult = NSMutableArray();
        indexes = NSArray();
        
        askTable.registerNib(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)

        
        var content :ReferralFilterContent = ReferralFilterContent()
        content.contactsGlosarry = ["Andy","Becky","Caroline","David"];
        
        //self.searchResult = content.glossaryIndex?.mutableCopy() as? NSMutableArray
        
        for var i = 0; i < content.contactsGlosarry!.count; i++ {
            
            var temps = content.contactsGlosarry!.objectAtIndex(i) as! String;
            self.currentContent!.addObject( content.productWithType(temps) );
            
        }
        
         //indexes = content.glossaryIndex?.sortedArrayUsingSelector("localizedCaseInsensitiveCompare:")
         self.searchResult = self.currentContent!;
         askTable.reloadData();
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
        self.searchResult?.removeAllObjects(); // First clear the filtered array.
    
        /*  
        
        Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
        
        */
        
        var product: ReferralFilterContent?
        
        for product in self.currentContent! {
            
            println("what products see -> \(product.name)")
            
            var searchOptions = NSStringCompareOptions.CaseInsensitiveSearch | NSStringCompareOptions.DiacriticInsensitiveSearch;
            var productNameRang = Range<String.Index>(start: productName.startIndex, end: productName.endIndex);
            var foundRange =  product.name.substringWithRange(productNameRang) as  String;
            
            if (foundRange == productName) {
                self.searchResult?.addObject(product);
            }
        
        }
        
    }

    // MARK: -- UITableViewDataSource --
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.searchResult!.count;
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 76;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:ContactsCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ContactsCell
        
        /*if (self.data[indexPath.section] != nil) {
            cell.loadData(self.data[indexPath.section][indexPath.row])
        } else {
            println("Strange index in contacts table: ", indexPath)
        }*/
        
        
        cell.name.text = self.searchResult!.objectAtIndex(indexPath.row).name as String
        
        
        return cell
    }
    
    // MARK: -- UITableViewDelegate --
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Go to profile view
        let storyboard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var genericController = storyboard.instantiateViewControllerWithIdentifier("GenericProfileView") as! GenericProfileViewController
        genericController.viewType = 2;
        genericController.isEditable = false;
        self.navigationController?.pushViewController(genericController, animated: true)
        
    }
    
    @IBAction func askAction(sender: AnyObject) {
        
        popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
        popup!.bodyText("You have successfully asked 3 contacts for referral");
        popup!.delegate = self;
        self.view.addSubview(popup!);
        
    }
    
    @IBAction func closeAction(sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func dismissPopUp() {
        
        popup!.removeFromSuperview();
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
        
}

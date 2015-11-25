//
//  AskReferralViewController.swift
//  Nudge
//
//  Created by Antonio on 30/06/2015.
//  Copyright (c) 2015 Lachezar Todorov. All rights reserved.
//

import UIKit
import CCMPopup

class AskReferralViewController: UIViewController, UISearchBarDelegate ,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CreatePopupViewDelegate{
    
    @IBOutlet var askTable: UITableView!
    @IBOutlet var searchBarView: UISearchBar!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var messageLabel: NZLabel!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!

    var jobId:Int?
    var isNudjRequest:Bool?
    var isSlideTransition:Bool?
    var filtering = FilterModel()
    
    var selected = [ContactModel]()
    var popup :CreatePopupView?;

    var messagePlaceholder:String?
    var jobTitle:String?
    
    let cellIdentifier = "ContactsCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.hidden = true
        
        if(self.isNudjRequest!){
            self.title = "Refer Someone"
        }else{
            
            if let job = self.jobTitle {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
                self.messageLabel.text = "Select contacts to ask for referrals, for the \(job) position"
                self.messageLabel.setFontColor(appDelegate.appColor, string:job)
                self.navigationItem.rightBarButtonItem?.title = "Ask"
            }
            
        }

        messagePlaceholder = messageText.text
        
        askTable.registerNib(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        
        askTable.tableFooterView = UIView(frame: CGRectZero)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            
            self.loadData()
        })
        
    }

    func loadData() {
        
        ContactModel.getContacts { status, response in
            if (!status) {
                
                self.askTable.hidden = false
                
                return
                
            }

            let dictionary = sorted(response["data"]) { $0.0 < $1.0 }
            var content = [ContactModel?]();
            
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
            
            self.filtering.setContent(content)
            self.askTable.hidden = false
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

    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if(searchBar.text == ""){
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }else{
            self.filtering.stopFiltering()
            searchBar.text = ""
            self.askTable.reloadData()
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
       
        searchBar.resignFirstResponder()
    }

    
    func searchBar(searchBar :UISearchBar, textDidChange searchText:String){
        
        searchBar.setShowsCancelButton(true, animated: true)
        
        if(!searchText.isEmpty){

            self.filtering.startFiltering(searchText, completionHandler: { (success) -> Void in
            })

        }else {
            self.filtering.stopFiltering()
        }

        self.askTable.reloadData()
    }



    // MARK: -- UITableViewDataSource --
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.filtering.filteredContent.count
        
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

        if let contact = self.filtering.filteredContent[indexPath.row] {
            cell.loadData(contact)

            if selected.count > 0 {

                for (index, value) in enumerate(selected) {
                    if value.id == contact.id {
                        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                        break
                    }
                }
            }
        }

        return cell
    }

    // MARK: -- UITableViewDelegate --
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        toggleRowSelection(indexPath)
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        toggleRowSelection(indexPath)
    }

    func toggleRowSelection(indexPath: NSIndexPath) {
        if let cell = askTable.cellForRowAtIndexPath(indexPath) as? ContactsCell {

            if let contact = self.filtering.filteredContent[indexPath.row] {

                for (index, value) in enumerate(selected) {
                    if value.id == contact.id {
                        selected.removeAtIndex(index)

                        cell.accessoryType = UITableViewCellAccessoryType.None

                        checkSelected()
                        return
                    }
                }

                selected.append(contact)

                cell.accessoryType = UITableViewCellAccessoryType.Checkmark

                checkSelected()

                return;
            }
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

        if(messageText.text == messagePlaceholder){
            messageText.text = nil
        }
        
        
        let params:[String:AnyObject] = ["job": "\(jobId!)", "contacts": contactIds, "message": messageText.text]
        

        self.messageText.resignFirstResponder()

        // TODO: Refactor
        if(self.isNudjRequest!){
            
            API.sharedInstance.put("nudge", params: params, closure: { result in
                self.navigationController?.navigationBarHidden = true
            
                self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
                
                let nudjContent = self.selected.count > 1 ? "\(self.selected[0].name) and \(self.selected.count - 1) others" : self.selected[0].name
                self.popup!.bodyText("You have successfully nudged \(nudjContent)");
                self.popup!.delegate = self;
                self.view.addSubview(self.popup!);
                
                //self.performSegueWithIdentifier("ShowPopup", sender: self)
                

                print(result)
                }) { error in
                    print(error)
            }
            
        }else{
            
            API.sharedInstance.put("nudge/ask", params: params, closure: { result in
                self.navigationController?.navigationBarHidden = true
                
                self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
                
                let nudjContent = self.selected.count > 1 ? "\(self.selected[0].name) and \(self.selected.count - 1) others" : self.selected[0].name
                self.popup!.bodyText("You have successfully asked \(nudjContent) for referral");
                self.popup!.delegate = self;
                self.view.addSubview(self.popup!);
                
                //self.performSegueWithIdentifier("ShowPopup", sender: self)
                
                print(result)
                }) { error in
                    print(error)
            }

            
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
       if segue.isKindOfClass(CCMPopupSegue) {
            var popupSegue = segue as! CCMPopupSegue
            popupSegue.destinationBounds = CGRectMake(0, 0, 300, 400);
            popupSegue.backgroundBlurRadius = 7;
            popupSegue.backgroundViewAlpha = 0.3;
            popupSegue.backgroundViewColor = UIColor.blackColor()
            popupSegue.dismissableByTouchingBackground = true
        }
        
    }
    
    
    @IBAction func close(sender: AnyObject) {
        self.closeCurrentView()
    }
    
    func dismissPopUp() {
        self.navigationController?.navigationBarHidden = false
       
        popup!.removeFromSuperview();
        self.closeCurrentView()
    }
    
    func closeCurrentView(){
        
        if isSlideTransition != nil && isSlideTransition == true {
           self.navigationController?.popViewControllerAnimated(true)
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
        
}

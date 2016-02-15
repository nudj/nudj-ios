//
//  AskReferralViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import CCMPopup

class AskReferralViewController: UIViewController, SegueHandlerType, UISearchBarDelegate ,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CreatePopupViewDelegate{
    
    enum SegueIdentifier: String {
        case ShowPopup = "ShowPopup"
    }
    
    @IBOutlet var askTable: UITableView!
    @IBOutlet var searchBarView: UISearchBar!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var messageLabel: NZLabel!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!

    var jobId:Int?
    var isNudjRequest:Bool?
    var filtering = FilterModel()
    
    var selected = Set<ContactModel>()
    var popup :CreatePopupView?;

    var messagePlaceholder:String?
    var jobTitle:String?
    
    let cellIdentifier = "ContactsCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.hidden = true
        
        if(self.isNudjRequest!){
            self.title = Localizations.Referral.Title
        } else {
            if let job = self.jobTitle {
                // TODO: eliminate singleton access
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
                self.messageLabel.text = Localizations.Referral.Ask.Format(job)
                self.messageLabel.setFontColor(appDelegate.appColor, string:job)
                self.navigationItem.rightBarButtonItem?.title = Localizations.Referral.Ask.Button
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
        ContactModel.getContacts { 
            status, response in
            if (!status) {
                self.askTable.hidden = false
                return
            }

            // TODO: API strings
            let dictionary = response["data"].sort{ $0.0 < $1.0 }
            var content = [ContactModel]();
            
            for (_, parentObj) in dictionary {
                for (_, obj) in parentObj {
                    var user:UserModel? = nil

                    if(obj["user"].type != .Null) {
                        user = UserModel()
                        user!.updateFromJson(obj["user"])
                    }

                    let contact = ContactModel(id: obj["id"].intValue, name: obj["alias"].stringValue, apple_id: obj["apple_id"].stringValue, user: user)
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
        // TODO: Use proper UIKit placeholder
        if(textView.text == Localizations.Referral.Message.Placeholder){
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
        // TODO: do we need this?
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // TODO: do we need this?
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if(searchBar.text == ""){
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        } else {
            self.filtering.stopFiltering()
            searchBar.text = ""
            self.askTable.reloadData()
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(searchBar :UISearchBar, textDidChange searchText:String) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        if(!searchText.isEmpty){
            self.filtering.startFiltering(searchText, completionHandler: { _ in })
        } else {
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
        // TODO: magic number
        return 76;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ContactsCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? ContactsCell
        
        if cell == nil {
            tableView.registerNib(UINib(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
            cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? ContactsCell
        }

        let contact = self.filtering.filteredContent[indexPath.row] 
        cell.loadData(contact)
        
        if selected.count > 0 {
            for value in selected {
                if value.id == contact.id {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    break
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
            let contact = self.filtering.filteredContent[indexPath.row]
            if selected.contains(contact) {
                selected.remove(contact)
                cell.accessoryType = UITableViewCellAccessoryType.None
            } else {
                selected.insert(contact)
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
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

        if(messageText.text == messagePlaceholder){
            messageText.text = nil
        }
        
        let params = API.Endpoints.Nudge.paramsForJob(jobId!, contactIDs: contactIds, message: messageText.text)        
        self.messageText.resignFirstResponder()
        AppDelegate.registerForRemoteNotifications()

        // TODO: Refactor
        guard let firstSelected = self.selected.first else {return}
        if(self.isNudjRequest!){
            let path = API.Endpoints.Nudge.base
            API.sharedInstance.request(.PUT, path: path, params: params, closure: { result in
                self.navigationController?.navigationBarHidden = true
                
                self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
                
                let nudjContent: String
                if self.selected.count == 1 {
                    nudjContent = Localizations.Referral.Nudge.Sent.Singular.Format(firstSelected.name)
                } else {
                    nudjContent = Localizations.Referral.Nudge.Sent.Plural.Format(firstSelected.name, self.selected.count - 1)
                }
                self.popup!.bodyText(nudjContent);
                self.popup!.delegate = self;
                self.view.addSubview(self.popup!);
                
                loggingPrint(result)
                }) { error in
                    loggingPrint(error)
            }
        } else {
            let path = API.Endpoints.Nudge.ask
            API.sharedInstance.request(.PUT, path: path, params: params, closure: { result in
                self.navigationController?.navigationBarHidden = true
                
                self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
                
                let nudjContent: String
                if self.selected.count == 1 {
                    nudjContent = Localizations.Referral.Ask.Sent.Singular.Format(firstSelected.name)
                } else {
                    nudjContent = Localizations.Referral.Ask.Sent.Plural.Format(firstSelected.name, self.selected.count - 1)
                }
                self.popup!.bodyText(nudjContent);
                self.popup!.delegate = self;
                self.view.addSubview(self.popup!);
                
                loggingPrint(result)
                }) { error in
                    loggingPrint(error)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowPopup:
            let popupSegue = segue as! CCMPopupSegue
            // TODO: magic numbers
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
        self.navigationController?.popViewControllerAnimated(true)
    }
}

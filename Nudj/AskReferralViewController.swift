//
//  AskReferralViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import CCMPopup
import SwiftyJSON

class AskReferralViewController: UIViewController, SegueHandlerType, UISearchBarDelegate ,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CreatePopupViewDelegate{
    
    enum SegueIdentifier: String {
        case ShowPopup = "ShowPopup"
    }
    
    @IBOutlet var askTable: UITableView!
    @IBOutlet var searchBarView: UISearchBar!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!

    var jobId:Int?
    var isNudjRequest:Bool?
    
    // TODO: refactor out the data source of AskReferralViewController and ContactsController
    var isSearchEnabled: Bool = false
    var filtering = FilterModel()
    var indexes = [String]()
    var data = [String:[ContactModel]]()
    
    var selected = Set<ContactModel>()
    var popup :CreatePopupView?

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
                let appColor = ColorPalette.nudjGreen
                let plainString = Localizations.Referral.Ask.Format(job)
                let messageAtrributedString = NSMutableAttributedString(string: plainString)
                let range = (plainString as NSString).rangeOfString(job)
                messageAtrributedString.addAttribute(NSForegroundColorAttributeName, value: appColor, range: range)
                messageLabel.attributedText = messageAtrributedString
            }
            navigationItem.rightBarButtonItem?.title = Localizations.Referral.Ask.Button
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
            var content = [ContactModel]()
            
            for (id, obj) in dictionary {
                if self.data[id] == nil {
                    self.indexes.append(id)
                    self.data[id] = [ContactModel]()
                }
                
                for (_, subJson) in obj {
                    var isUser = false
                    var user: UserModel? = nil
                    var userContact: JSON?
                    
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
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isSearchEnabled = false
        if searchBar.text?.isEmpty ?? true {
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
        self.isSearchEnabled = true
    }

    func searchBar(searchBar :UISearchBar, textDidChange searchText:String) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        if(!searchText.isEmpty){
            self.filtering.startFiltering(searchText, completionHandler: { _ in 
                self.isSearchEnabled = true
                self.askTable.reloadData()
            })
        } else {
            self.filtering.stopFiltering()
            self.isSearchEnabled = false
            self.askTable.reloadData()
        }
    }

    // MARK: -- UITableViewDataSource --

    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isSearchEnabled {
            return nil
        } else {
            return self.indexes[section]
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isSearchEnabled {
            return 1
        }else{
            return self.indexes.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchEnabled {
            return self.filtering.filteredContent.count
        } else {
            if let section = self.data[indexes[section]] {
                return section.count
            }
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ContactsCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ContactsCell
        cell.removeSelectionStyle()
        let contact: ContactModel
        if self.isSearchEnabled {
            contact = self.filtering.filteredContent[indexPath.row]
            cell.loadData(contact)
        } else {
            let index = indexes[indexPath.section]
            
            if let section = self.data[index] {
                contact = section[indexPath.row]
                cell.loadData(contact)
            } else {
                loggingPrint("Strange index in contacts table: ", indexPath.debugDescription)
                return cell
            }
        }
        
        if selected.contains(contact) {
            cell.accessoryType = .Checkmark
        }

        return cell
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.isSearchEnabled ? nil : self.indexes
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
                cell.accessoryType = .None
            } else {
                selected.insert(contact)
                cell.accessoryType = .Checkmark
            }

            checkSelected()
        }
    }

    func checkSelected() {
        self.navigationItem.rightBarButtonItem?.enabled = !selected.isEmpty
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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.registerForRemoteNotifications()

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

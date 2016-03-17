//
//  AskReferralViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import CCMPopup
import SwiftyJSON

class AskReferralViewController: UIViewController, SegueHandlerType, UISearchBarDelegate, UITableViewDelegate, UITextViewDelegate, CreatePopupViewDelegate{
    
    enum SegueIdentifier: String {
        case ShowPopup = "ShowPopup"
    }
    
    @IBOutlet var askTable: UITableView!
    @IBOutlet var searchBarView: UISearchBar!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!

    var jobId: Int?
    var isNudjRequest: Bool?
    
    let dataSource = ContactsDataSource()
    var popup: CreatePopupView?

    var messagePlaceholder: String?
    var jobTitle: String?
    
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
        dataSource.registerNib(askTable)
        askTable.dataSource = dataSource
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

            self.dataSource.loadData(data: response["data"])
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
        dataSource.isSearchEnabled = false
        if searchBar.text?.isEmpty ?? true {
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
       } else {
            dataSource.stopFiltering()
            searchBar.text = ""
        }
        askTable.reloadData()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dataSource.isSearchEnabled = true
        askTable.reloadData()
    }

    func searchBar(searchBar :UISearchBar, textDidChange searchText:String) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        if(!searchText.isEmpty){
            dataSource.startFiltering(searchText, completionHandler: {
                self.dataSource.isSearchEnabled = true
                self.askTable.reloadData()
            })
        } else {
            dataSource.stopFiltering()
            dataSource.isSearchEnabled = false
            askTable.reloadData()
        }
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
            let contact = dataSource.contactForIndexPath(indexPath)
            let contactID = contact.id
            
            let newSelected = !dataSource.isSelected(contactID)
            dataSource.setSelected(contactID, selected: newSelected)
            cell.accessoryType = newSelected ? .Checkmark : .None

            checkSelected()
        }
    }

    func checkSelected() {
        self.navigationItem.rightBarButtonItem?.enabled = dataSource.hasSelection()
    }

    @IBAction func askAction(sender: AnyObject) {
        self.resignFirstResponder()
        self.view.endEditing(true)
        
        if messageText.text == messagePlaceholder {
            messageText.text = nil
        }
        let contactIDs = dataSource.selectedContactIDs()
        if contactIDs.isEmpty {
            return
        }
        let contactsCount = contactIDs.count
        
        let params = API.Endpoints.Nudge.paramsForJob(jobId!, contactIDs: contactIDs, message: messageText.text)        
        self.messageText.resignFirstResponder()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.registerForRemoteNotifications()

        // TODO: Refactor
        guard let firstSelected = dataSource.contactWithID(contactIDs[0]) else {return}
        if(self.isNudjRequest!){
            let path = API.Endpoints.Nudge.base
            API.sharedInstance.request(.PUT, path: path, params: params, closure: { result in
                self.navigationController?.navigationBarHidden = true
                
                self.popup = CreatePopupView(x: 0, yCordinate: 0, width: self.view.frame.size.width , height: self.view.frame.size.height, imageName:"success", withText: true);
                
                let nudjContent: String
                if contactIDs.count == 1 {
                    nudjContent = Localizations.Referral.Nudge.Sent.Singular.Format(firstSelected.name)
                } else {
                    nudjContent = Localizations.Referral.Nudge.Sent.Plural.Format(firstSelected.name, contactsCount - 1)
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
                if contactIDs.count == 1 {
                    nudjContent = Localizations.Referral.Ask.Sent.Singular.Format(firstSelected.name)
                } else {
                    nudjContent = Localizations.Referral.Ask.Sent.Plural.Format(firstSelected.name, contactsCount - 1)
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

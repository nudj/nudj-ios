//
//  FirstViewController.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class MainFeed: BaseController, SegueHandlerType, DataProviderProtocol, UISearchBarDelegate {
    
    enum SegueIdentifier: String {
        case GoToJob = "goToJob"
        case AddJob = "AddJob"
    }

    @IBOutlet weak var table: DataTable!

    var selectedJobData:JSON? = nil

    @IBOutlet weak var searchBar: UISearchBar!
    var blackBackground = UIView()
    var searchTerm:String?
    var noContentImage = NoContentPlaceHolder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.asignCellNib("JobCellTableViewCell")
        self.table.dataProvider = self as DataProviderProtocol
        self.table.delegate = self.table
        self.table.dataSource = self.table
        self.table.selectedClosure = goToJob
        
        self.blackBackground.hidden = true
        self.blackBackground.alpha = 0.7
        self.blackBackground.backgroundColor = UIColor.blackColor()
        self.blackBackground.frame = self.view.frame
        self.view.addSubview(self.blackBackground)
        
        self.view.bringSubviewToFront(self.searchBar)
        self.view.addSubview(self.noContentImage.alignInSuperView(self.view, imageTitle: "no_jobs"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MixPanelHandler.sendData("JobsTabOpened")
        self.tabBarController?.tabBar.hidden = false
        
        if(searchTerm == nil){
            self.table.loadData()
        }
    }
    
    func requestData(page: Int, size: Int, listener: (JSON) -> ()) {
        let imageName = (searchTerm == nil) ? "no_jobs" : "no_search_results"
        self.noContentImage.image = UIImage(named: imageName)
        
        let path = API.Endpoints.Jobs.search(searchTerm)
        let params = API.Endpoints.Jobs.paramsForList(page, pageSize: size)
        self.apiRequest(.GET, path: path, params: params, closure: listener)
    }
    
    func deleteData(id: Int, listener: (JSON) -> ()) {
        // only implemented to conform to DataProviderProtocol
    }
    
    func didfinishLoading(count: Int) {
        noContentImage.hidden = (count > 0)
    }

    @IBAction func addJob(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate // TODO: use dependency injection instead
        let user = appDelegate.user
        if (user.name?.isEmpty ?? true) || (user.email?.isEmpty ?? true) || (user.company?.isEmpty ?? true) {
            // user needs to supply at least name, email and company
            let localization = Localizations.Jobs.Add.self
            let alert = UIAlertController(title: localization.NeedProfile.Title, message: localization.NeedProfile.Body, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: Localizations.General.Button.Cancel, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let editProfileAction = UIAlertAction(title: localization.Button.EditProfile, style: .Default) {
                alertAction in
                self.editProfile(alertAction, user: user, requiredFields: [.Name, .Email, .Company], completionHandler: {
                    _ in
                    self.performSegueWithIdentifier(.AddJob, sender: sender)
                })
            }
            alert.addAction(editProfileAction)
            alert.preferredAction = editProfileAction
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier(.AddJob, sender: sender)
        }
    }
    
    func editProfile(alertAction: UIAlertAction, user: UserModel, requiredFields: GenericProfileViewController.Fields, completionHandler: GenericProfileViewController.CompletionHandler) {
        let genericProfileVC = GenericProfileViewController.instantiateWithUserID(user.id ?? 0, type: .Own, requiredFields: requiredFields, completionHandler: completionHandler)
        self.navigationController?.pushViewController(genericProfileVC, animated:true)
    }
    
    func goToJob(job:JSON) {
        selectedJobData = job
        performSegueWithIdentifier(.GoToJob, sender: self) 
    }
    
    @IBAction func unwindToJobsList(segue: UIStoryboardSegue) {
        // nothing to do here
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .AddJob:
            break
        case .GoToJob:
            let detailsView = segue.destinationViewController as! JobDetailedViewController
            detailsView.jobID = selectedJobData!["id"].intValue
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.stopSearcAction()
        searchBar.text = ""
        searchTerm = nil
        self.table.loadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        //self.blackBackground.hidden = false
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchTerm = searchBar.text
        self.table.loadData()
        self.stopSearcAction()
    }
    
    func stopSearcAction(){
        //self.navigationController?.navigationBarHidden = false
        //self.searchBar.hidden = true
        searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
    }
}

//
//  MainTabBar.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

final class MainTabBar: UITabBarController, SegueHandlerType {
    enum Notifications: String {
        case UpdateBadge
    }
    
    enum SegueIdentifier: String {
        case ShowLogin = "ShowLogin"
        case UnwindToJobsList = "unwindToJobsList"
    }
    
    enum UpdateBadgeKeys: String {
        case TabIndex, BadgeString
    }
    
    enum Tabs: Int {
        case Jobs = 0, Chats, Contacts, Notifications, Settings 
    }
    
    private var pendingDestination = Destination.None
    private var loggingInViewShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(updateBadge(_:)), name: Notifications.UpdateBadge.rawValue, object: nil)
    }
    
    static func postBadgeNotification(badgeString: String, tabIndex: Tabs) {
        let nc = NSNotificationCenter.defaultCenter()
        let notificationName = Notifications.UpdateBadge.rawValue
        let payload: [String: AnyObject] = [
            UpdateBadgeKeys.TabIndex.rawValue: tabIndex.rawValue,
            UpdateBadgeKeys.BadgeString.rawValue: badgeString,
        ]
        nc.postNotificationName(notificationName, object: nil, userInfo: payload)
    }
    
    func updateBadge(notification: NSNotification) {
        guard let userInfo = notification.userInfo, 
            let tabIndex = userInfo[UpdateBadgeKeys.TabIndex.rawValue] as? Int else {
                return
        }
        
        guard let tabArray = tabBar.items else {return}
        if(tabArray.count > tabIndex){
            let tabItem = tabArray[tabIndex]
            let badgeString = userInfo[UpdateBadgeKeys.BadgeString.rawValue] as? String
            tabItem.badgeValue = badgeString
        }
    }
    
    func selectTab(tab: Tabs) {
        selectedIndex = tab.rawValue
    }
    
    func viewControllerForTab(tab: Tabs) -> UIViewController {
        return viewControllers![tab.rawValue]
    }
    
    @IBAction func showLogin(sender: AnyObject?) {
        loggingInViewShown = true
        performSegueWithIdentifier(.ShowLogin, sender: sender)
    }
    
    func loginSucessful(verifyViewController: VerifyViewController) {
        verifyViewController.performSegueWithIdentifier(.UnwindToJobsList, sender: self)
        loggingInViewShown = false
        goToDestination(pendingDestination)
    }
    
    func goToDestination(destination: Destination) {
        if destination == .None {
            return
        }
        
        if loggingInViewShown {
            // defer this destination until that is resolved
            pendingDestination = destination
            return
        }
        
        defer {
            pendingDestination = .None
        }
        
        switch destination {
        case .None:
            break
            
        case .Job(let jobID):
            selectTab(.Jobs)
            let jobsNavController = viewControllerForTab(.Jobs) as! UINavigationController
            jobsNavController.popToRootViewControllerAnimated(true)
            let jobsViewController = jobsNavController.viewControllers.first as! MainFeed
            jobsViewController.goToJob(jobID)
        }
    }
}

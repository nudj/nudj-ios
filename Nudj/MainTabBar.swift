//
//  MainTabBar.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class MainTabBar: UITabBarController {
    enum Notifications: String {
        case UpdateBadge
    }
    
    enum UpdateBadgeKeys: String {
        case TabIndex, BadgeString
    }
    
    enum Tabs: Int {
        case Jobs = 0, Chats, Contacts, Notifications, Settings 
    }
    
    override func viewDidLoad() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:"updateBadge:", name: Notifications.UpdateBadge.rawValue, object: nil)
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
}

//
//  NoContactsPermissionController.swift
//  Nudj
//
//  Created by Lachezar Todorov on 6.08.15.
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit

class NoContactsPermissionController: UIViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

        if (appDelegate.contacts.isAuthorized()) {
            appDelegate.changeRootViewController("mainNavigationController")
        }
    }
    
    @IBAction func goToSettings(sender: AnyObject) {
        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        if let url = settingsUrl {
            UIApplication.sharedApplication().openURL(url)
        }
    }

}

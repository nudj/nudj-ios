//
//  AppDelegate.swift
//  NudjData
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import Mixpanel
import SwiftyJSON
import HockeySDK

@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {
    
    enum ViewControllerIdentifier: String {
        case Main = "mainNavigation"
        case Login = "loginController"
    }

    var window: UIWindow?
    var user = UserModel()
    var api: API?
    private let coreDataStack = CoreDataStack()
    private var chatDelegate: AppChatDelegate! // TODO: try to make this a let
    var chatInst: ChatModels?
    var deviceToken: String?
    private var deviceTokenSynced: Bool = false
    var contacts = Contacts()
    
    //Mix panel
    let MIXPANEL_TOKEN = "29fc1fec9fa6f75efd303f12c8be4acb"
    
    /// read the HockeyApp ID, if any, from the Info.plist file
    func hockeyAppIdentifier() -> String? {
        let hockeyAppKey = "HockeyAppID"
        let bundle = NSBundle.mainBundle()
        return bundle.objectForInfoDictionaryKey(hockeyAppKey) as? String
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Mixpanel
        Mixpanel.sharedInstanceWithToken(MIXPANEL_TOKEN)
        MixPanelHandler.startEventTracking("timeSpentInApplication")
        
        // HockeyApp
        if let hockeyAppIdentifier = self.hockeyAppIdentifier() {
            BITHockeyManager.sharedHockeyManager().configureWithIdentifier(hockeyAppIdentifier)
            // Do some additional configuration if needed here
            BITHockeyManager.sharedHockeyManager().startManager()
            BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        }
        
        // Getting of user details from CoreData
        fetchUserData()
        prepareApi();
        
        if user.id != nil {
            // valid user
            prefetchUserData()
        } else {
            showLogin(self)
        }
        
		// we only register for notifications if we have a valid user
		if user.completed {
			registerForRemoteNotifications()
            user.fetchBlockedUsers()
		}
        
        if contacts.isAuthorized() {
            self.syncContacts()
        }
        
        //Setup XMPP and connect
        chatInst = ChatModels()
        self.chatDelegate = AppChatDelegate(chatInst: chatInst!)
        chatInst!.delegate = self.chatDelegate
        if(!chatInst!.connect(user, inViewController: self.window!.rootViewController!)) {
            // TODO: decide what to do here
        }

        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject: AnyObject] {
            self.application(application, didReceiveRemoteNotification: remoteNotification)
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // TODO: deprecated in iOS 9
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.deviceToken = deviceToken.hexString()
        deviceTokenSynced = false
        syncDeviceToken()
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // TODO: better error handling
        loggingPrint( "Notification Error: ", error.localizedDescription )
    }

    func registerForRemoteNotifications() {
        let application = UIApplication.sharedApplication()
        if(application.isRegisteredForRemoteNotifications() && deviceToken != nil) {
            syncDeviceToken()
            return
        }
        let types: UIUserNotificationType = [.Badge, .Alert, .Sound]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didReceiveRemoteNotification remoteNotification: [NSObject: AnyObject]) {
        if let notification = remoteNotification["aps"], 
            let notificationCount = notification["badge"] as? Int {
                application.applicationIconBadgeNumber = notificationCount
                let badgeString = "\(notificationCount)"
                MainTabBar.postBadgeNotification(badgeString, tabIndex: .Notifications)
        }
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        switch userActivity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            guard let url = userActivity.webpageURL else {
                return false
            }
            let destination = Destination(url: url)
            switch destination {
            case .None:
                application.openURL(url)
                
            default:
                goToDestination(destination)
            }
            return true
            
        default:
            return false
        }
    }
    
    func showLogin(sender: AnyObject?) {
        let mainTabBarController = window?.rootViewController as! MainTabBar
        mainTabBarController.showLogin(sender)
    }
    
    func loginSucessful(verifyViewController: VerifyViewController) {
        let mainTabBarController = window?.rootViewController as! MainTabBar
        mainTabBarController.loginSucessful(verifyViewController)
    }

    func goToDestination(destination: Destination) {
        let mainTabBarController = window?.rootViewController as! MainTabBar
        mainTabBarController.goToDestination(destination)
    }
    
    func syncContacts() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),{
            self.contacts.sync()
        })
    }

    func syncDeviceToken() {
        if (API.sharedInstance.token == nil) {
            return
        }
        if deviceTokenSynced {
            return
        }
        
        if let deviceToken = self.deviceToken {
            let path = API.Endpoints.Devices.base
            let params = API.Endpoints.Devices.params(deviceToken)
            API.sharedInstance.request(.PUT, path: path, params: params, closure:{ 
                _ in
                self.deviceTokenSynced = true
            });
        }
    }

    func fetchUserData() {
        // TODO: refactor to a single-responsibility object
        guard let moc = coreDataStack.managedObjectContext else {
            // TODO: better error handling
            loggingPrint("No managedObjectContext")
            return
        }
        
        do {
            let fetchRequest = NSFetchRequest(entityName:"User")
            let results = try moc.executeFetchRequest(fetchRequest)
            
            if (results.count > 0) {
                let obj = results.first as! NSManagedObject
                
                // TODO: straighten out the data model and use mogenerator
                user.id = obj.valueForKey("id") as? Int
                user.name = obj.valueForKey("name") as? String
                user.token = obj.valueForKey("token") as? String
                user.completed = obj.valueForKey("completed")?.boolValue ?? false
                user.addressBookAccess = obj.valueForKey("addressBookAccess")?.boolValue ?? false
                user.status = obj.valueForKey("status") as? Int ?? 0
            }
        }
        catch let error as NSError {
            loggingPrint("Could not fetch \(error), \(error.userInfo)")
        }
    }

    func prefetchUserData() {
        if self.user.token != nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                // TODO: API strings
                let fields = UserModel.fieldsForProfile + ["user.completed", "user.settings"]
                UserModel.getCurrent(fields, closure: { 
                    userObject in
                    if let source :JSON = userObject.source {
                        self.user.updateFromJson(source)
                        self.pushUserData()
                    }
                })
            })
        }
    }

    func pushUserData() {
        // TODO: API strings
        // TODO just make self.user a managed object. This duplication is nuts
        let moc = coreDataStack.managedObjectContext!
        do {
            let fetchRequest = NSFetchRequest(entityName:"User")
            let results = try moc.executeFetchRequest(fetchRequest)
            
            var userObject = results.first as? NSManagedObject
            if (userObject == nil) {
                let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext: moc)
                userObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
            }
            guard let obj = userObject else {return}
            obj.setValue(user.id, forKey: "id")
            obj.setValue(user.name, forKey: "name")
            obj.setValue(user.token, forKey: "token")
            obj.setValue(user.completed, forKey: "completed")
            obj.setValue(user.addressBookAccess, forKey: "addressBookAccess")
            obj.setValue(user.status, forKey: "status")
        }
        catch let error as NSError {
            loggingPrint("Could not fetch \(error), \(error.userInfo)")
        }

        do {
            try moc.save()
        }
        catch let error as NSError {
            loggingPrint("Could not save \(error), \(error.userInfo)")
        }
    }

    func deleteUserData() {
        let moc = coreDataStack.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"User")

        do {
            let fetchedResults = try moc.executeFetchRequest(fetchRequest)
            for obj in fetchedResults {
                let user = obj as! NSManagedObject
                loggingPrint("Deleting: ", user.debugDescription)
                moc.deleteObject(user)
            }
            
            do {
                try moc.save() 
            }
            catch let error as NSError {
                loggingPrint("Save error \(error), \(error.userInfo)")
            }
        }
        catch let error as NSError {
            loggingPrint("Fetch error \(error), \(error.userInfo)")
        }
    }

    func deleteAllData() {
        self.deleteUserData()
        self.deleteChatData()
        API.sharedInstance.token = nil
        self.api?.token = nil
    }
    
    func deleteAccount(inViewController viewController: UIViewController){
        API.sharedInstance.request(.DELETE, path: API.Endpoints.Users.me, params: nil, closure: { 
            response in
            if response["status"].boolValue {
                self.deleteAllData()
                self.showLogin(self)
            } else {
                let localization = Localizations.Account.Delete.Error.self
                let alert = UIAlertController(title: localization.Title, message: localization.Body, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                alert.preferredAction = cancelAction
                viewController.presentViewController(alert, animated: true, completion: nil)
            }
            
            }, 
            errorHandler: {
                error in
                let localization = Localizations.Account.Delete.Error.self
                let alert = UIAlertController(title: localization.Title, message: localization.Body, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: Localizations.General.Button.Ok, style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                alert.preferredAction = cancelAction
                viewController.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func deleteChatData(){
        let defaults = NSUserDefaults.standardUserDefaults()
        var chatRoom = self.chatInst!.listOfActiveChatRooms
        for (key, _) in  chatRoom {
            if let chat = chatRoom[key]{
                chat.teminateSession()
                chatRoom.removeValueForKey(key)
                chat.deleteStoredChats()
                defaults.setObject(nil, forKey:key)
            }
        }
        defaults.synchronize()
    }

    func prepareApi() {
        // TODO: why do we have both a sharedInstance and an instance variable?
        API.sharedInstance.token = self.user.token
        if (api == nil) {
            api = API()
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        MixPanelHandler.stopEventTracking("timeSpentInApplication")
        coreDataStack.saveContext()
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        MixPanelHandler.startEventTracking("timeSpentInApplication")
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        MixPanelHandler.stopEventTracking("timeSpentInApplication")
        coreDataStack.saveContext()
        // TODO: review the below, why commented out
//        self.chatInst!.xmppRoom?.leaveRoom()
//        self.chatInst!.xmppRoom?.deactivate()
//        self.chatInst!.xmppRoom?.removeDelegate(self)
    }
}

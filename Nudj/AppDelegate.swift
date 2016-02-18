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
class AppDelegate: NSObject, UIApplicationDelegate, ChatModelsDelegate {
    
    enum ViewControllerIdentifier: String {
        case Main = "mainNavigation"
        case Login = "loginController"
    }

    var window: UIWindow?
    var user = UserModel()
    var api: API?
    var chatInst: ChatModels?
    var deviceToken: String?
    private var deviceTokenSynced: Bool = false
    var contacts = Contacts()
    
    var shouldShowBadge = false
    var appWasInBackground = false
    var pushNotificationsPayload: NSDictionary?
    
    //Mix panel
    let MIXPANEL_TOKEN = "29fc1fec9fa6f75efd303f12c8be4acb"
    
    // TOOD: refactor these out
    let appColor = UIColor(red: 0.0, green: 0.63, blue: 0.53, alpha: 1.0)
    let appBlueColor = UIColor(red:17.0/255.0, green:147.0/255.0, blue:189.0/255.0, alpha: 1.0)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Mixpanel
        Mixpanel.sharedInstanceWithToken(MIXPANEL_TOKEN)
        MixPanelHandler.startEventTracking("timeSpentInApplication")
        
        // HockeyApp
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("9bb5535d31f24908a06d72757a8e39e9")
        // Do some additional configuration if needed here
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        // Getting of user details from CoreData
        fetchUserData()
        prepareApi();
        
        if user.id != nil {
            // valid user
            prefetchUserData()
            showViewControllerWithIdentifier(.Main)
        } else {
            // user needs to login - the login screen is currently the default start view but don't rely on that
            showViewControllerWithIdentifier(.Login)
        }
        
		// we only register for notifications if we have a valid user
		if user.completed {
			registerForRemoteNotifications()
		}
        
        if contacts.isAuthorized() {
            self.syncContacts()
        }
        
        //Setup XMPP and connect
        chatInst = ChatModels()
        chatInst!.delegate = self;
        if(!chatInst!.connect(inViewController: self.window!.rootViewController!)) {
            // TODO: decide what to do here
        }

        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            pushNotificationsPayload = remoteNotification
        }
        
        if pushNotificationsPayload != nil && pushNotificationsPayload!.count > 0 {
            if let notification: AnyObject = pushNotificationsPayload!.valueForKey("aps") {
                let notificationCount :Int = notification["badge"] as! Int
                UIApplication.sharedApplication().applicationIconBadgeNumber = notificationCount
                // TODO: why 3?
                NSNotificationCenter.defaultCenter().postNotificationName("updateBadgeValue", object: nil, userInfo: ["value":"\(notificationCount)","index":"3"])
                pushNotificationsPayload = nil
            }
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

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // Update badge
        let userinfo = userInfo as NSDictionary
        loggingPrint(userinfo)
        
        if let notification: AnyObject = userinfo.valueForKey("aps") {
            let notificationCount :Int =  notification.valueForKey("badge") as! Int
            UIApplication.sharedApplication().applicationIconBadgeNumber = notificationCount
            // TODO: why 3?
            NSNotificationCenter.defaultCenter().postNotificationName("updateBadgeValue", object: nil, userInfo: ["value":"\(notificationCount)","index":"3"])
        }
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
        guard let moc = self.managedObjectContext else {
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
                UserModel.getCurrent(["user.name", "user.completed", "user.status", "user.image","user.settings"], closure: { 
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
        let moc = self.managedObjectContext!
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
        let moc = self.managedObjectContext!
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

    func showViewControllerWithIdentifier(identifier: ViewControllerIdentifier) {
        self.window!.rootViewController = self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier(identifier.rawValue)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        appWasInBackground = true
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        FBSDKAppEvents.activateApp()

        if (appWasInBackground) {
            appWasInBackground = false
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        MixPanelHandler.stopEventTracking("timeSpentInApplication")
        self.saveContext()
        // TODO: review the below, why commented out
//        self.chatInst!.xmppRoom?.leaveRoom()
//        self.chatInst!.xmppRoom?.deactivate()
//        self.chatInst!.xmppRoom?.removeDelegate(self)
    }

    // MARK: - Core Data stack
    // TODO: refactor out

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("NudgeData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("NudgeData.sqlite")
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true, 
                NSInferMappingModelAutomaticallyOption: true]
            try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } 
        catch let error as NSError {
            loggingPrint("Error opening the Core Data store \(error)")
            do {
                let fileManager = NSFileManager()
                try fileManager.removeItemAtURL(url)
                try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            }
            catch let error as NSError {
                loggingPrint("Error creating a new Core Data store \(error)")
                return nil
            }
        }
        
        return coordinator
        }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
        // This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        // TODO: JRB: No, the above line is rubbish. We must be able to recover from any failure.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext.init(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            do {
                try moc.save()
            }
            catch let error as NSError {
                // TODO: error handling
                loggingPrint("Save error: \(error)")
            }
        }
    }
    
    // MARK: JABBER Delegate Methods
    // TODO: refactor JABBER Delegate into spearate object
    
    func recievedUser(content: NSDictionary) {
        // TODO: determine what to do
    }
    
    func recievedMessage(content: JSQMessage, conference: String) {
        if(shouldShowBadge) {
            //Store message as it's new
            let roomID = self.chatInst!.getRoomIdFromJidString(conference)
            
            loggingPrint("Saving new message \(roomID)")
            let defaults = NSUserDefaults.standardUserDefaults()
            if let outData = defaults.dataForKey(roomID) {
                if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                    var diction = dict
                    
                    //overwrite previous data if it exsists
                    diction["isRead"] = false
                    let data = NSKeyedArchiver.archivedDataWithRootObject(diction)
                    defaults.setObject(data, forKey:roomID)
                    defaults.synchronize()
                }
            }
            
            // Update badge
            // TODO: magic numbers
            NSNotificationCenter.defaultCenter().postNotificationName("updateBadgeValue", object: nil, userInfo: ["value":"1","index":"1"])
            
            // reload table
            NSNotificationCenter.defaultCenter().postNotificationName("reloadChatTable", object: nil, userInfo:nil)
        }
    }

    func handleEjabberedRecievedMessages(){
        // TODO: determine what to do
    }
    
    func isRecievingMessageIndication(user: String) {
        // TODO: determine what to do
    }
}

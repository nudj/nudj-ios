//
//  AppDelegate.swift
//  NudgeData
//
//  Created by Lachezar Todorov on 26.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import Mixpanel
import ReachabilitySwift
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ChatModelsDelegate {

    var window: UIWindow?
    var user: UserModel?
    var api: API?
    var chatInst: ChatModels?
    var deviceToken: String?
    var deviceTokenSynced:Bool = false
    var contacts = Contacts()
    
    var shouldShowBadge = false
    var appWasInBackground = false
    var pushNotificationsPayload :NSDictionary?
    
    //Tutorial options
    var shouldShowAddJobTutorial = true
    var shouldShowNudjTutorial = true
    var shouldShowAskForReferralTutorial = true
    
    //Mix panel
    let MIXPANEL_TOKEN = "29fc1fec9fa6f75efd303f12c8be4acb"
    let appColor = UIColor(red: 0.0, green: 0.63, blue: 0.53, alpha: 1.0)
    let appBlueColor = UIColor(red:17.0/255.0, green:147.0/255.0, blue:189.0/255.0, alpha: 1.0)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Mixpanel
        Mixpanel.sharedInstanceWithToken(MIXPANEL_TOKEN)
        MixPanelHandler.startEventTracking("timeSpentInApplication")
        
        // Getting of user details from CoreData
        fetchUserData()
        prepareApi();
        print("usercompleted is  -> \(self.user?.completed)")
        
        if (user != nil && user!.id != nil && user!.completed == false) {
            if (contacts.isAuthorized()) {
                // User did not passed full registration
                self.syncContacts()
                self.pushViewControllerWithId("createProfile")
            } else {
                self.showContactsAccessView()
            }
        } else if (user == nil) {
            // Invalid user Require Login
            // Proceed to login view
        } else {
            prefetchUserData()

            if (contacts.isAuthorized()) {
                // Valid User, Proceed
                self.changeRootViewController("mainNavigation")
                self.syncContacts()
            } else {
                self.showContactsAccessView()
            }
        }
        
        //Setup XMPP and connect
        chatInst = ChatModels()
        chatInst!.delegate = self;
        if(!chatInst!.connect()) {
            print("NOT Connected to chat server so will try reconnecting")
        }

        requestNotificationPermission(application)
        //pushNotificationsPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
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
        
        //Handle internet connection
        self.beginInternetConnectionCheck()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // TODO: deprecated in iOS 9
        if(LISDKCallbackHandler.shouldHandleUrl(url)){
            return LISDKCallbackHandler.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )

        self.deviceToken = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String

        syncDeviceToken()
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // TODO: better error handling
        print( "Notification Error: ", error.localizedDescription )
    }

    func requestNotificationPermission(application: UIApplication) {
        let types: UIUserNotificationType = [.Badge, .Alert, .Sound]
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        /*type_id = 8
        [aps: {
            alert = "Is it working, Ant?";
            badge = 0;
            sound = "bingbong.aiff";
            }, meta: {
                "chat_id" = 4;
        }]*/
        
        // Update badge
        let userinfo = userInfo as NSDictionary
        print(userinfo)
        
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

        if self.deviceToken != nil {
            print( "Device token sent -> \(self.deviceToken!)")
            // TODO: API strings
            API.sharedInstance.put("devices", params: ["token":self.deviceToken!], closure:{ 
                _ in
                self.deviceTokenSynced = true
            });
        }
    }

    func showContactsAccessView() {
        let askForPermission = NoContactsPermissionController(nibName: "NoContactsPermissionController", bundle: nil)
        self.window!.rootViewController = askForPermission
    }
    
    func beginInternetConnectionCheck(){
        // TODO: refactor to a single-responsibility object
       do {
            // TODO: audit this for callers and figure out what NoInternetConnectionView is for: it might be overkill
            let reachability = try Reachability.reachabilityForInternetConnection()
            let view = NoInternetConnectionView(frame: self.window!.frame)
            var isShown = false;
            
            reachability.whenUnreachable = { 
                reachability in
                print("Not reachable")
                if !isShown {
                    self.window?.addSubview(view)
                    isShown = true
                }
            }
            
            reachability.whenReachable = { 
                reachability in
                print("reachable")
                if isShown {
                    view.removeFromSuperview()
                    isShown = false
                }
            }
            
            try reachability.startNotifier()
        }
        catch let error {
            // TODO: figure out what to do here
            print("Reachability error: \(error)")
        }
    }

    func fetchUserData() {
        // TODO: refactor to a single-responsibility object
        guard let moc = self.managedObjectContext else {
            // TODO: better error handling
            print("No managedObjectContext")
            return
        }
        
        do {
            let fetchRequest = NSFetchRequest(entityName:"User")
            fetchRequest.fetchLimit = 1;
            let results = try moc.executeFetchRequest(fetchRequest)
            
            if (results.count > 0) {
                let user = self.user ?? UserModel()
                let obj = results.first as! NSManagedObject;
                
                user.id = obj.valueForKey("id") == nil ? nil : obj.valueForKey("id") as? Int
                user.name = obj.valueForKey("name") == nil ? nil : (obj.valueForKey("name") as! String)
                user.token = obj.valueForKey("token") == nil ? nil : (obj.valueForKey("token") as! String)
                user.completed = obj.valueForKey("completed") == nil ? false : (obj.valueForKey("completed") as! Bool)
                user.addressBookAccess = obj.valueForKey("addressBookAccess") == nil ? false : obj.valueForKey("addressBookAccess")!.boolValue
                user.status = obj.valueForKey("status") == nil ? 0 : obj.valueForKey("status") as! Int
                
                getUserObject()
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    func prefetchUserData() {
        if let user = self.user {
            if user.token != nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    // TODO: API strings
                    UserModel.getCurrent(["user.name", "user.completed", "user.status", "user.image","user.settings"], closure: { 
                        userObject in
                        if let source :JSON = userObject.source {
                            
                            if let settings :JSON = userObject.settings {
                                self.shouldShowAddJobTutorial = settings["tutorial"]["post_job"].boolValue
                                self.updateUserObject("AddJobTutorial", with: self.shouldShowAddJobTutorial)
                                
                                self.shouldShowAskForReferralTutorial = settings["tutorial"]["create_job"].boolValue
                                self.updateUserObject("AskForReferralTutorial", with: self.shouldShowAskForReferralTutorial)
                                
                                self.shouldShowNudjTutorial = settings["tutorial"]["open_job"].boolValue
                                self.updateUserObject("NudjTutorial", with:  self.shouldShowNudjTutorial)
                            }
                            self.user!.updateFromJson(source)
                            self.pushUserData()
                        }else{
                            print(" user has no source object")
                        }
                    })
                })
            } else {
                print(" user has no token")
            }
        } else {
            print("current user deleted")
        }
    }

    func pushUserData() {
        pushUserData(self.user!)
    }

    func pushUserData(user: UserModel) {
        if (self.user == nil) {
            self.user = user
        }

        let moc = self.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext: moc)
        let userObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        
        userObject.setValue(user.id == nil ? nil : NSInteger(user.id!), forKey: "id")
        userObject.setValue(user.name, forKey: "name")
        userObject.setValue(user.token, forKey: "token")
        userObject.setValue(user.completed, forKey: "completed")
        userObject.setValue(user.addressBookAccess, forKey: "addressBookAccess")
        userObject.setValue(user.status == nil ? nil : NSInteger(user.status!), forKey: "status")
        
        self.updateUserObject("Completed", with: user.completed)

        do {
            try moc.save()
            self.user = user
        }
        catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    func deleteUserData() {
        let moc = self.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"User")

        do {
            let fetchedResults = try moc.executeFetchRequest(fetchRequest)
            for obj in fetchedResults {
                let user = obj as! NSManagedObject
                print("Deleting: ", user)
                moc.deleteObject(user)
            }
            
            do {
                try moc.save() 
            }
            catch let error as NSError {
                print("Save error \(error), \(error.userInfo)")
            }
        }
        catch let error as NSError {
            print("Fetch error \(error), \(error.userInfo)")
        }
    }

    func logout() {
        self.deleteUserData()
        self.deleteChatData()
        self.deleteUserObject()        
        API.sharedInstance.token = nil
        self.api?.token = nil
    }
    
    func deleteAccount(){
        // TODO: API strings
        API.sharedInstance.request(.DELETE, path: "users/me", params: nil, closure: { 
            response in
            print("deleted account \(response)")
            if response["status"].boolValue {
                self.logout()
            }else{
                // TODO: localisation
                let alert = UIAlertView(title: "Error deleting account", message: "We were unable to delete your account, please try again.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            }, 
            errorHandler: {
                error in
                // TODO: localisation
                let alert = UIAlertView(title: "Error deleting account", message: "Oops something went wrong.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
        })
    }
    
    func deleteChatData(){
        var chatRoom = self.chatInst!.listOfActiveChatRooms
        for (id, _) in  chatRoom {
            if let chat = chatRoom[id]{
                chat.teminateSession()
                chatRoom.removeValueForKey(id)
                chat.deleteStoredChats()
                self.deleteNSuserDefaultContent(id)
            }
        }
    }

    func prepareApi() {
        API.sharedInstance.token = self.user?.token
        print("Token: \(API.sharedInstance.token)")
        if (api == nil) {
            api = API()
        }
    }

    func pushViewControllerWithId(id: String) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController:UINavigationController = storyboard.instantiateViewControllerWithIdentifier("mainNavigationController") as! UINavigationController
        let rootViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier(id) 
        navigationController.viewControllers = [rootViewController]
        self.window?.rootViewController = navigationController
    }

    func changeRootViewController(id:String) {
        self.window!.rootViewController = self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier(id)
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

            if (!contacts.isAuthorized()) {
                self.showContactsAccessView()
            }
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
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. 
        // This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // TODO: JRB: No, the above line is rubbish. We must be able to recover from any failure.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("NudgeData.sqlite")
        // TODO: lcoalisation
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch let error as NSError {
            // TODO: this error handling is unsatisfactory
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
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
        var managedObjectContext = NSManagedObjectContext()
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
                print("Save error: \(error)")
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
            let roomID = self.chatInst!.getRoomIdFromJid(conference)
            
            print("Saving new message \(roomID)")
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
    
    //MARK: - NSUSERDEFAULT
    // TODO: refactor Chat properties
    
    func saveNSUserDefaultContent(id:String, params:[String:Bool]){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let outData = defaults.dataForKey(id) {
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                var diction = dict
                
                if(params["isRead"] != nil){
                    diction["isRead"] = params["isRead"]
                }
                
                if(params["isNew"] != nil){
                    diction["isNew"] = params["isNew"]
                }
                
                let data = NSKeyedArchiver.archivedDataWithRootObject(diction)
                defaults.setObject(data, forKey:id)
                defaults.synchronize()
            }
        } else {
            //TODO: Handle this
        }
    }
    
    func getNSUserDefaultContent(id:String, value:String) -> Int{
        let defaults = NSUserDefaults.standardUserDefaults()
        if let outData = defaults.dataForKey(id) {
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                let diction = dict[value]
                return Int(diction!)
            }
        }
        // TODO: why 2?
        return 2
    }
    
    func deleteNSuserDefaultContent(id:String){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let _ = defaults.dataForKey(id) {
            defaults.setObject(nil, forKey:id)
            defaults.synchronize()
            print("Deleted NSuserDefaultdata id:\(id)")
        }
    }
    
    //CURRENT USER
    func createUserObject(){
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // TODO: magic strings
        let dict = ["Completed":false, "AddJobTutorial":true, "NudjTutorial":true, "AskForReferralTutorial":true]
        let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
        
        defaults.setObject(data, forKey:"USER")
        defaults.synchronize()
        
        self.getUserObject()
    }
    
    func getUserObject(){
        let defaults = NSUserDefaults.standardUserDefaults()
        // TODO: magic strings
        if let outData = defaults.dataForKey("USER") {
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                print(dict)
                
                if dict["Completed"] != nil {
                    self.user!.completed = dict["Completed"]!.boolValue
                }
                
                self.shouldShowNudjTutorial =  dict["NudjTutorial"]!.boolValue
                self.shouldShowAskForReferralTutorial = dict["AskForReferralTutorial"]!.boolValue
                self.shouldShowAddJobTutorial = dict["AddJobTutorial"]!.boolValue
            }else{
                print("error in reading NSUserDefaults USER")
            }
        } else {
            self.createUserObject()
        }
    }
    
    func updateUserObject(title:String, with value:Bool){
        let defaults = NSUserDefaults.standardUserDefaults()
        // TODO: magic strings
        if let outData = defaults.dataForKey("USER") {
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                 if dict[title] != nil {
                    var newContent = dict
                    newContent[title] = value
                    let data = NSKeyedArchiver.archivedDataWithRootObject(newContent)
                    defaults.setObject(data, forKey:"USER")
                    defaults.synchronize()
                    print("Updated \(title) with \(value)")
                 }
            } else {
                // TODO: better error handling
                print("error in reading NSUserDefaults USER")
            }
        } else {
            // Cannot put in USER as it doesnt exist so create one
            self.createUserObject()
            
            // user has been created. now let's retry putting
            updateUserObject(title, with: value)
        }
    }
    
    func deleteUserObject(){
        // TODO: magic strings
        let defaults = NSUserDefaults.standardUserDefaults()
        if let _ = defaults.dataForKey("USER") {
            defaults.setObject(nil, forKey:"USER")
            defaults.synchronize()
        }
    }
    
    func createTestCaseForUserinfo(){
        // TODO: move to test suite
        // TODO: magic strings
        let defaults = NSUserDefaults.standardUserDefaults()
        if let outData = defaults.dataForKey("USER") {
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                var dic = dict
                dic["Completed"] = false
                dic["NudjTutorial"] = false
                dic["AskForReferralTutorial"] = false
                dic["AddJobTutorial"] = false
                let data = NSKeyedArchiver.archivedDataWithRootObject(dic)
                defaults.setObject(data, forKey:"USER")
                defaults.synchronize()
                
                getUserObject()
            }
        }
    }
}


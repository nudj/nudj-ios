//
//  AppDelegate.swift
//  NudgeData
//
//  Created by Lachezar Todorov on 26.02.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import FBSDKLoginKit
import Mixpanel
import ReachabilitySwift
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ChatModelsDelegate{

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
    let appColor = UIColor(red: 0, green: 0.63, blue: 0.53, alpha: 1)
    let appBlueColor = UIColor(red:17.0/255.0, green:147.0/255.0, blue:189.0/255.0, alpha: 1)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Fabric
        Fabric.with([Crashlytics()])
        
        //Mixpanel
        Mixpanel.sharedInstanceWithToken(MIXPANEL_TOKEN)
        MixPanelHandler.startEventTracking("timeSpentInApplication")
        
        // Getting of user details from CoreData
        fetchUserData()
        prepareApi();
        println("usercompleted is  -> \(self.user?.completed)")
        
        if (user != nil && user!.id != nil && user!.completed == false) {

            if (contacts.isAuthorized()) {
                // User did not passed full registration
                self.syncContacts()
                self.pushViewControllerWithId("createProfile")
            } else{
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
            
            println("NOT Connected to chat server so will try reconnecting !!!")
            
        }

        requestNotificationPermission(application)
        //pushNotificationsPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            pushNotificationsPayload = remoteNotification
        }
        
        
        if pushNotificationsPayload != nil && pushNotificationsPayload?.count > 0{
            
            if let notification: AnyObject = pushNotificationsPayload!.valueForKey("aps") {
                var notificationCount :Int = notification["badge"] as! Int
                UIApplication.sharedApplication().applicationIconBadgeNumber = notificationCount
                NSNotificationCenter.defaultCenter().postNotificationName("updateBadgeValue", object: nil, userInfo: ["value":"\(notificationCount)","index":"3"])
                pushNotificationsPayload = nil
            }
            
        }
        
        //Handle internet connection
        self.beginInternetConnectionCheck()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    
        if(LISDKCallbackHandler.shouldHandleUrl(url)){
            
            return LISDKCallbackHandler.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )

        self.deviceToken = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String

        syncDeviceToken()
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println( "Notification Error: ", error.localizedDescription )
    }

    func requestNotificationPermission(application: UIApplication) {
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound

        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )

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
        println(userinfo)
        
        if let notification: AnyObject = userinfo.valueForKey("aps") {
            
            var notificationCount :Int =  notification.valueForKey("badge") as! Int
            UIApplication.sharedApplication().applicationIconBadgeNumber = notificationCount
            
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
            println( "Device token sent -> \(self.deviceToken!)")
            API.sharedInstance.put("devices", params: ["token":self.deviceToken!], closure:{ _ in
                self.deviceTokenSynced = true
            });
        }
    }

    func showContactsAccessView() {
        let askForPermission = NoContactsPermissionController(nibName: "NoContactsPermissionController", bundle: nil)
        self.window!.rootViewController = askForPermission
    }
    
    func beginInternetConnectionCheck(){
        
        let reachability = Reachability.reachabilityForInternetConnection()
        var view = NoInternetConnectionView(frame: self.window!.frame)
        var isShown = false;
        
        reachability.whenUnreachable = { reachability in
            println("Not reachable")
            
            if !isShown {
                self.window?.addSubview(view)
                isShown = true
            }
        }
        
        reachability.whenReachable = { reachability in
            println("reachable")
            if isShown {
                view.removeFromSuperview()
                isShown = false
            }
        }
        
        reachability.startNotifier()
    }

    func fetchUserData() {

        let managedContext = self.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"User")
        fetchRequest.fetchLimit = 1;

        var error: NSError?

        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error)

        if let results = fetchedResults {
            if (results.count > 0) {
                if (self.user == nil) {
                    self.user = UserModel()
                }

                let obj = results.first as! NSManagedObject;

                self.user!.id = obj.valueForKey("id") == nil ? nil : obj.valueForKey("id") as? Int
                self.user!.name = obj.valueForKey("name") == nil ? nil : (obj.valueForKey("name") as! String)
                self.user!.token = obj.valueForKey("token") == nil ? nil : (obj.valueForKey("token") as! String)
                self.user!.completed = obj.valueForKey("completed") == nil ? false : (obj.valueForKey("completed") as! Bool)
                self.user!.addressBookAccess = obj.valueForKey("addressBookAccess") == nil ? false : obj.valueForKey("addressBookAccess")!.boolValue
                self.user!.status = obj.valueForKey("status") == nil ? 0 : obj.valueForKey("status") as! Int
             
                getUserObject()
            }

        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }

    }

    func prefetchUserData() {
        if let user = self.user {
            if user.token != nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    UserModel.getCurrent(["user.name", "user.completed", "user.status", "user.image","user.settings"], closure: { userObject in
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
                            
                            println(" user has no source object")
                            
                        }
                    })
                })
            }else {
                
                println(" user has no token")
                
            }
        }else{
            
            println("current user deleted")
        
        }
        
        
    }

    func pushUserData() {
        pushUserData(self.user!)
    }

    func pushUserData(user: UserModel) {
        if (self.user == nil) {
            self.user = user
        }

        let managedContext = self.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        let userObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        

        userObject.setValue(user.id == nil ? nil : NSInteger(user.id!), forKey: "id")
        userObject.setValue(user.name, forKey: "name")
        userObject.setValue(user.token, forKey: "token")
        userObject.setValue(user.completed, forKey: "completed")
        userObject.setValue(user.addressBookAccess, forKey: "addressBookAccess")
        userObject.setValue(user.status == nil ? nil : NSInteger(user.status!), forKey: "status")
        
        self.updateUserObject("Completed", with: user.completed)

        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        } else {
            self.user = user
        }
    }

    func deleteUserData() {
        let managedContext = self.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"User")

        var error: NSError?

        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error)

        if let results = fetchedResults {
            if (results.count > 0) {
                for obj in results {
                    let user = obj as! NSManagedObject
                    println("Deleted: ", user)
                    managedContext.deleteObject(user)
                }

                if !managedContext.save(&error) {
                    println("Could remove user details \(error), \(error?.userInfo)")
                }
            }
        } else {
            println("Could not find active user \(error), \(error!.userInfo)")
        }
        
        
    }

    func logout() {
        
        self.deleteUserData()
        self.deleteChatData()
        self.deleteUserObject()
        
        API.sharedInstance.token = nil
        
        if self.api != nil {
            self.api?.token = nil
        }
        
    }
    
    func deleteAccount(){
        
        API.sharedInstance.request(.DELETE, path: "users/me", params: nil, closure: { response in
            
            println("deleted account \(response)")
            
            if response["status"].boolValue {
            
                self.logout()
            
            }else{
                
                var alert = UIAlertView(title: "Error deleting account", message: "We were unable to delete your account, please try again.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()

            }
            
        }, errorHandler: { error in
                
                var alert = UIAlertView(title: "Error deleting account", message: "Oops something went wrong.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
        })
        
    }
    
    func deleteChatData(){
        
        var chatRoom = self.chatInst!.listOfActiveChatRooms
        for (id, obj) in  chatRoom {
            if let chat = chatRoom[id]{
                
                chat.teminateSession()
                chatRoom.removeValueForKey(id)
                println("removed from list")
                chat.deleteStoredChats()
                self.deleteNSuserDefaultContent(id)
            
            }
        }
        
        
    }

    func prepareApi() {
        API.sharedInstance.token = self.user?.token

        println("Token: \(API.sharedInstance.token)")

        if (api == nil) {
            api = API()
        }
    }

    func pushViewControllerWithId(id: String) {
        println("Go To: " + id)

        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController:UINavigationController = storyboard.instantiateViewControllerWithIdentifier("mainNavigationController") as! UINavigationController
        let rootViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier(id) as! UIViewController
        navigationController.viewControllers = [rootViewController]
        self.window?.rootViewController = navigationController
    }

    func changeRootViewController(id:String) {
        self.window!.rootViewController = self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier(id) as? UIViewController
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
        
//        self.chatInst!.xmppRoom?.leaveRoom()
//        self.chatInst!.xmppRoom?.deactivate()
//        self.chatInst!.xmppRoom?.removeDelegate(self)
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "e-man.NudgeData" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("NudgeData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("NudgeData.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }

        return coordinator
        }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
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
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    
    // MARK: JABBER Delegate Methods
    
    func recievedUser(content: NSDictionary) {
       
        
    }
    
    func recievedMessage(content: JSQMessage, conference: String) {
        
        if(shouldShowBadge == true){

            //Store message as its new
            var roomID = self.chatInst!.getRoomIdFromJid(conference)
            
            println("Saving new message \(roomID)")
            let defaults = NSUserDefaults.standardUserDefaults()
            if let outData = defaults.dataForKey(roomID) {
            
                if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                    var diction = dict
                    
                    //overwrite previous data if it exsists
                    diction["isRead"] = false
                    var data = NSKeyedArchiver.archivedDataWithRootObject(diction)
                    defaults.setObject(data, forKey:roomID)
                    defaults.synchronize()
                    
                }
            }
            
            // Update badge
            NSNotificationCenter.defaultCenter().postNotificationName("updateBadgeValue", object: nil, userInfo: ["value":"1","index":"1"])
            
            // reload table
            NSNotificationCenter.defaultCenter().postNotificationName("reloadChatTable", object: nil, userInfo:nil)
            

        }


    }

    func handleEjabberedRecievedMessages(){

        
    }
    
    func isRecievingMessageIndication(user: String) {
        
        
    }
    

    //MARK: - NSUSERDEFAULT
    //Chat properties
    
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
                    
                    var data = NSKeyedArchiver.archivedDataWithRootObject(diction)
                    defaults.setObject(data, forKey:id)
                    defaults.synchronize()
                    
                }
            }else{
            
                //TODO: Handle this
                
            }
    
        
    }
    
    
    func getNSUserDefaultContent(id:String, value:String) -> Int{
     
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let outData = defaults.dataForKey(id) {
            
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                
                var diction = dict[value]
                return Int(diction!)
                
            }
        }
        
        return 2
    }
    
    func deleteNSuserDefaultContent(id:String){
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let outData = defaults.dataForKey(id) {
            
            defaults.setObject(nil, forKey:id)
            defaults.synchronize()
            
            println("Deleted NSuserDefaultdata id:\(id)")
        
        }
    
    }
    
    
    //CURRENT USER
    func createUserObject(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var dict = ["Completed":false, "AddJobTutorial":true, "NudjTutorial":true, "AskForReferralTutorial":true]
        var data = NSKeyedArchiver.archivedDataWithRootObject(dict)
        
        defaults.setObject(data, forKey:"USER")
        defaults.synchronize()
        
        self.getUserObject()
        
        println("Created NSUserDefaults USER")
        
    }
    
    func getUserObject(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let outData = defaults.dataForKey("USER") {
            
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                
                println(dict)
                
                if dict["Completed"] != nil {
                    self.user!.completed = dict["Completed"]!.boolValue
                }
                
                self.shouldShowNudjTutorial =  dict["NudjTutorial"]!.boolValue
                
                self.shouldShowAskForReferralTutorial = dict["AskForReferralTutorial"]!.boolValue
                
                self.shouldShowAddJobTutorial = dict["AddJobTutorial"]!.boolValue
                
            }else{
                
                println("error in reading NSUserDefaults USER")
            }
            
        }else{
            
            self.createUserObject()
        }
        
    }
    
    func updateUserObject(title:String, with value:Bool){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let outData = defaults.dataForKey("USER") {
            
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
            
                 if dict[title] != nil {
                    
                    var newContent = dict
                    newContent[title] = value
                    var data = NSKeyedArchiver.archivedDataWithRootObject(newContent)
                    defaults.setObject(data, forKey:"USER")
                    defaults.synchronize()
                    println("Updated \(title) with \(value)")
                    
                 }
            
            }else{
                
                println("error in reading NSUserDefaults USER")
            }
            
        }else{
            
            println("Cannot put in USER as it doesnt exsist so let create one")
            self.createUserObject()
            
            println("OK SO user has been created. now let retry putting")
            updateUserObject(title, with: value)
            
        }

    }
    
    func deleteUserObject(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let outData = defaults.dataForKey("USER") {
         
            defaults.setObject(nil, forKey:"USER")
            defaults.synchronize()

        
            println("Deleted userobject")
        }
        
        
    }
    
    func createTestCaseForUsefinfo(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let outData = defaults.dataForKey("USER") {
            
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as? [String:Bool] {
                var dic = dict
                dic["Completed"] = false
                dic["NudjTutorial"] = false
                dic["AskForReferralTutorial"] = false
                dic["AddJobTutorial"] = false
                var data = NSKeyedArchiver.archivedDataWithRootObject(dic)
                defaults.setObject(data, forKey:"USER")
                defaults.synchronize()
                
                getUserObject()
            }
        }
    }
}


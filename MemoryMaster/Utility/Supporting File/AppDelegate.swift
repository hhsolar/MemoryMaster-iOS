//
//  AppDelegate.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        checkFirstLaunch()
        setSingletonValue()
        
        UINavigationBar.appearance().barTintColor = CustomColor.medianBlue
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        return true
    }
    
    private func checkFirstLaunch() {
        let launchBefore = UserDefaults.standard.bool(forKey: "launchBefore")
        if launchBefore == false {
            UserDefaults.standard.set(true, forKey: "launchBefore")
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.switchStatus)
            
            let userInfoDict: [String : String] = [UserDefaultsDictKey.userName: "", UserDefaultsDictKey.userMotto: ""]
            UserDefaults.standard.set(userInfoDict, forKey: UserDefaultsKeys.userInfo)
            
            let statusDict: [String : Any] = [UserDefaultsDictKey.id: 0, UserDefaultsDictKey.cardIndex: 0, UserDefaultsDictKey.readType: "", UserDefaultsDictKey.cardStatus: ""]
            UserDefaults.standard.set(statusDict, forKey: UserDefaultsKeys.lastReadStatus)
        }
    }

    private func setSingletonValue() {
        if var dict = UserDefaults.standard.dictionary(forKey: UserDefaultsKeys.userInfo) {
            UserInfo.shared.userName = dict[UserDefaultsDictKey.userName] as! String
            UserInfo.shared.userMotto = dict[UserDefaultsDictKey.userMotto] as! String
        }
        SoundSwitch.shared.isSoundOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.switchStatus)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        setUserDefaultValue()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        setUserDefaultValue()
        self.saveContext()
    }
    
    private func setUserDefaultValue() {
        UserDefaults.standard.set(SoundSwitch.shared.isSoundOn, forKey: UserDefaultsKeys.switchStatus)
        
        if var dict = UserDefaults.standard.dictionary(forKey: UserDefaultsKeys.userInfo) {
            dict.updateValue(UserInfo.shared.userName, forKey: UserDefaultsDictKey.userName)
            dict.updateValue(UserInfo.shared.userMotto, forKey: UserDefaultsDictKey.userMotto)
            UserDefaults.standard.set(dict, forKey: UserDefaultsKeys.userInfo)
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MemoryMaster")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


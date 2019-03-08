//
//  AppDelegate.swift
//  GiphySharer
//
//  Created by Michael on 07/03/19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
            Branch.setUseTestBranchKey(true)
            debugPrint("*********** Using Branch Test Key *********** ")
        #endif
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = MainViewController()
        let navController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navController
        
        // Initialize branch
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // Branch.getInstance()?.validateSDKIntegration()
            if let error = error {
                debugPrint("Error initializing BranchSDK: \(error)")
                return
            }
            print("Branch params received: \(String(describing: params))")
            guard let params = params as? [String: AnyObject],
                let imageID = params["imageID"] as? String else {
                return
            }
            navController.pushViewController(ImageViewController(giphyID: imageID), animated: true)
        }
        // Branch.getInstance().setDebug()
        
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // handler for Push Notifications
        Branch.getInstance().handlePushNotification(userInfo)
    }

}


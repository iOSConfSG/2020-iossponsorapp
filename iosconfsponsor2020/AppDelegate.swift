//
//  AppDelegate.swift
//  iosconfsponsor2020
//
//  Created by Hotha Santhanakrishnan Swarup on 8/1/20.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import UIKit
import Lock
import Firebase
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let firebaseOptions = FirebaseOptions.init(googleAppID: Secrets.googleApiKey, gcmSenderID: Secrets.gcmSenderID)
        firebaseOptions.apiKey = Secrets.googleApiKey
        firebaseOptions.bundleID = Bundle.main.bundleIdentifier!
        firebaseOptions.clientID = Secrets.googleClientID
        firebaseOptions.databaseURL = Secrets.googleDatabaseURL
        firebaseOptions.googleAppID = Secrets.googleAppID
        FirebaseApp.configure(options: firebaseOptions)
        
        IQKeyboardManager.shared.enable = true

        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return Lock.resumeAuth(url, options: options)
    }
}


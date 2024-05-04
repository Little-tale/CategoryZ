//
//  AppDelegate.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/9/24.
//

import UIKit
import IQKeyboardManagerSwift
import iamport_ios

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.disabledToolbarClasses = [ CommentViewController.self ]
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [CommentViewController.self]
        
        if #available(iOS 15, *) {
            let appearnace = UINavigationBarAppearance()
            appearnace.configureWithOpaqueBackground()
            appearnace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : JHColor.black]
            appearnace.backgroundColor = JHColor.white
            UINavigationBar.appearance().standardAppearance = appearnace
            UINavigationBar.appearance().compactAppearance = appearnace
            UINavigationBar.appearance().scrollEdgeAppearance = appearnace
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Iamport.shared.receivedURL(url)
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        return  UIInterfaceOrientationMask.portrait // 세로모드
    }

}


//
//  SceneDelegate.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/9/24.
//

import UIKit
import Kingfisher

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
    
        guard let scene = (scene as? UIWindowScene) else { return }
        let navCon = UINavigationController(rootViewController: LunchScreenViewController())
        // ()
        window = UIWindow(windowScene: scene)
        window?.rootViewController = navCon
        window?.makeKeyAndVisible()
        //  GetStartViewController // GetStartViewController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
       
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
  
    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        ChatSocketManager.shared.startSocket()
      
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        ChatSocketManager.shared.stopSocket()
    }


}


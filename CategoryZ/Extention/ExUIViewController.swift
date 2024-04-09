//
//  ExUIViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import UIKit

extension UIViewController {
    
    func changeRootView(to viewController: UIViewController, isNavi: Bool = false) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        let sceneDelegate = windowScene.delegate as? SceneDelegate
        let vc = isNavi ? UINavigationController(rootViewController: viewController) : viewController
        sceneDelegate?.window?.rootViewController = vc
        sceneDelegate?.window?.makeKey()
    }
    
}

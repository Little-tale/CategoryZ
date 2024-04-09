//
//  ExUIViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import UIKit
import RxSwift
import RxCocoa

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

extension Reactive where Base: UIViewController {
    
    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(base.viewWillAppear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(base.viewWillDisappear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewWillDisapear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(base.viewWillDisappear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewDidDisapear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}

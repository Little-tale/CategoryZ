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
    
    func goLoginView() {
        let vc = LoginViewController()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        let sceneDelegate = windowScene.delegate as? SceneDelegate
    
        sceneDelegate?.window?.rootViewController = vc
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}

extension Reactive where Base: UIViewController {
    
    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(base.viewWillAppear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(base.viewDidAppear))
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


extension UIViewController {
    
    func showAlert(title: String, message : String? = nil, actionTitle: String? = nil , complite: @escaping ((UIAlertAction) -> Void)) {
        
        let alertCon = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let actionTitle {
            let action = UIAlertAction(title: actionTitle, style: .default) { action  in
                complite(action)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alertCon.addAction(action)
            alertCon.addAction(cancel)
        } else {
            let check = UIAlertAction(title: "확인", style: .default) { action in
                complite(action)
            }
            alertCon.addAction(check)
        }
        present(alertCon,animated: true)
    }
    
    func showAlert(error: NetworkError, actionTitle: String? = nil , complite: ((UIAlertAction) -> Void)? = nil) {
        
        let alertCon = UIAlertController(title: "Error", message: error.message, preferredStyle: .alert)
        
        if let actionTitle {
            let action = UIAlertAction(title: actionTitle, style: .default) { action  in
                complite?(action)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alertCon.addAction(action)
            alertCon.addAction(cancel)
        } else {
            let check = UIAlertAction(title: "확인", style: .default) { action in
                complite?(action)
            }
            alertCon.addAction(check)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in
            self?.present(alertCon,animated: true)
        }

    }
    
}

// MARK: 권한 설정 페이지 이동
extension UIViewController {
    
    func SettingAlert(){
        showAlert(title: "권한 없음", message: "카메라 권한이 있어야만 합니다.", actionTitle: "이동하기") {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
    
    func goSetting(){
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl)
        } else {
            showAlert(title: "실패", message: "이동하기 실패") { _ in
            }
        }
    }
   
}

// UIScreen.main 대체 2
extension UIViewController {
    
    func getScreen() -> UIScreen? {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
           
            return view.window?.windowScene?.screen
        }
        
        return window.screen
    }
}

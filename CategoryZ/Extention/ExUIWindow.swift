//
//  ExUIWindow.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/11/24.
//

import UIKit

//UI Screen.main.bound 대체
extension UIWindow {
    static var current: UIWindow? {
        // 모든 연결된 씬을 순회하면서 활성윈도우 씬을 찾기
        let activeScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }

        // 활성 씬에서 첫 키 윈도우를 찾기
        for scene in activeScenes {
            if let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow
            }
        }
        return nil
    }
    
}

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}


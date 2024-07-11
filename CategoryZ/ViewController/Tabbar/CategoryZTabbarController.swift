//
//  CategoryZTabbarController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa


final class CategoryZTabbarController: UITabBarController, UITabBarControllerDelegate {
    
    // 1. 메인
    // 2. 등록
    // 3. 프로필
    let disposeBag = DisposeBag()
    
    let networkMonitor = NetWorkServiceMonitor.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setupMiddleButton()
        settingTabBarItems()
        subscribe()
        view.backgroundColor = JHColor.white
        tabBar.isTranslucent = false
        delegate = self
    }
    
    func settingTabBarItems() {
        let homeImage = JHImage.homeImage?.resizingImage(
            targetSize: CGSize(width: 26, height: 26)
        )
        if let homeImage {
            homeImage.withRenderingMode(.alwaysTemplate)
        }
         
        
        let profileImage = JHImage.profileImage?.resizingImage(targetSize: CGSize(width: 26, height: 26))
        
        if let profileImage {
            profileImage.withRenderingMode(.alwaysTemplate)
        }
        
        // SNSPhotoViewController
        let controller1 = SNSPhotoViewController()
        let tabItem1 = UITabBarItem(
            title: nil,
            image: homeImage,
            selectedImage: homeImage
        )
        
        tabItem1.tag = 1
        controller1.tabBarItem = tabItem1
        let nvc1 = UINavigationController(rootViewController: controller1)
        
        // ADDViewController But is Empty cus if Presentation
        let dummyVc = UIViewController()
        let tabbarItem2 = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "plus.circle"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )
        dummyVc.tabBarItem = tabbarItem2
        
        let controller4 = ChattingListViewController()
        
        let tabbarItem4 = UITabBarItem(
            title: nil,
            image: JHImage.ChatTap.dis.image,
            selectedImage: JHImage.ChatTap.select.image
        )
        tabbarItem4.tag = 3
        controller4.tabBarItem = tabbarItem4
        let nv4 = UINavigationController(rootViewController: controller4)
        
        
        // UserProfileViewController
        let controller3 = UserProfileViewController()
        let tabItem3 = UITabBarItem(
            title: nil,
            image: profileImage,
            selectedImage: profileImage
        )
        
        tabItem3.tag = 4
        controller3.tabBarItem = tabItem3
        
        let nvc2 = UINavigationController(rootViewController: controller3)
        
        viewControllers = [nvc1, dummyVc, nv4, nvc2]
        tabBar.tintColor = JHColor.black
    }
    
    // MARK: ADD 눌렀을때의 동작을 위해서 ... 원래의 버튼을 제거합니다.
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // AddButtonViewController
        if viewController == viewControllers?[1] {
            presentedPostRegViewController()
            return false
        }
        return true
    }
    
    func presentedPostRegViewController() {
        let vc = PostRegViewController()
        vc.modalPresentationStyle = .pageSheet
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 100
        return sizeThatFits
    }
}


extension CategoryZTabbarController {
    
    func subscribe(){
        NotificationCenter.default.rx.notification(.successPost)
            .bind(with: self) { owner, _ in
                owner.selectedIndex = 0
            }
            .disposed(by: disposeBag)
        
        networkMonitor.behaivorNetwork
            .distinctUntilChanged()
            .filter({ $0 == false })
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "네트워크 불안정", message: "네트워크 연결 상태가 불안정합니다.\n네트워크 연결상태를 확인하여 주세요!")
            }
            .disposed(by: disposeBag)
        
        rx.viewDidDisapear
            .bind(with: self) { owner, _ in
                print("Stop Monitoring")
                owner.networkMonitor.stopMonitoring()
            }
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .bind(with: self) { owner, _ in
                print("Start Monitor")
                owner.networkMonitor.startMonitor()
            }
            .disposed(by: disposeBag)
        
        
    }
}




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


final class CategoryZTabbarController: UITabBarController {
    
    // 1. 메인
    // 2. 등록
    // 3. 프로필
    let disposeBag = DisposeBag()
    
    let addButton = UIButton().then {
        $0.backgroundColor = JHColor.likeColor
        $0.frame.size = CGSize(width: 60, height: 60)
    }
    
    let networkMonitor = NetWorkServiceMonitor.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupMiddleButton()
        settingTabBarItems()
        subscribe()
    }
    
    func settingTabBarItems() {
        let homeImage = JHImage.homeImage?.resizingImage(targetSize: CGSize(width: 30, height: 30))
        
        let profileImage = JHImage.profileImage?.resizingImage(targetSize: CGSize(width: 26, height: 26))

        // SNSPhotoViewController
        let controller1 = SNSPhotoViewController()
        let tabItem1 = UITabBarItem(title: nil, image: homeImage, selectedImage: homeImage)
        tabItem1.tag = 1
        controller1.tabBarItem = tabItem1
        
        let nvc1 = UINavigationController(rootViewController: controller1)

        let controller2 = UserProfileViewController()
        let tabItem2 = UITabBarItem(title: nil, image: profileImage, selectedImage: profileImage)
        tabItem2.tag = 2
        controller2.tabBarItem = tabItem2
        
        let nvc2 = UINavigationController(rootViewController: controller2)
        
        viewControllers = [nvc1, nvc2]
        tabBar.tintColor = JHColor.black
    }

    
    func setupMiddleButton() {
        view.addSubview(addButton)
        addButton.backgroundColor = JHColor.likeColor
        
        addButton.tintColor = JHColor.likeColor  // 이미지의 색상 설정
        
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-15)
            make.size.equalTo(60)
        }
        if let image = JHImage.addImageNormal {
            
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
            
           let configuredImage =  image.withConfiguration(imageConfig)
            
            addButton.layer.cornerRadius = addButton.frame.height / 2
            addButton.setImage(configuredImage, for: .normal)
            addButton.tintColor = JHColor.white
        }
        
        addButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let vc = PostRegViewController()
                vc.modalPresentationStyle = .pageSheet
                let nvc = UINavigationController(rootViewController: vc)
                owner.present(nvc, animated: true)
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.hidesBottomBarWhenPushed)
            .bind(with: self) { owner, _ in
                owner.setTabBarHidden(true, animated: true)
        }
        .disposed(by: disposeBag)
        
        
        navigationController?.navigationBar.isHidden = true
       
    }
    
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !tabBar.isHidden {
            setTabBarHidden(tabBar.isHidden, animated: true)
        }
        view.bringSubviewToFront(addButton)
    }
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0) {
            [weak self] in
            
            self?.tabBar.isHidden = hidden
            self?.addButton.tintColor = hidden ? .clear : JHColor.white
            self?.addButton.backgroundColor = hidden ? .clear : JHColor.likeColor
            self?.addButton.isEnabled = !hidden
            self?.view.layoutIfNeeded()
        }
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




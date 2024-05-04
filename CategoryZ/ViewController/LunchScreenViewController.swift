//
//  LunchScreenViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/16/24.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

final class LunchScreenViewController: RxHomeBaseViewController<FirstView> {
    
    let viewModel = FirstViewValidViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeView.animaionView.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        homeView.animaionView.stop()
    }
    
    override func subscribe() {
        
        let input = FirstViewValidViewModel.Input(viewdidAppearTrigger: rx.viewDidAppear)
        
        let output = viewModel.transform(input)
            
        output.changeViewController
            .delay(.seconds(2))
            .drive(with: self) { owner, bool in
                if bool {
                    // 현재는 이렇게 하지만 후에 탭바 컨트롤러로 교체
                    let viewController = CategoryZTabbarController()
                    let nvc = UINavigationController(rootViewController: viewController)
                    nvc.navigationBar.isHidden = true
                    
                    owner.changeRootView(to: nvc, isNavi: false)
                } else {
                    let viewController = GetStartViewController()
                    
                    let nvc = UINavigationController(rootViewController: viewController)
                    nvc.modalPresentationStyle = .fullScreen
                    owner.present(nvc, animated: true)
                }
            }
            .disposed(by: disPoseBag)
        
    }
    
    deinit {
        print("bye: LunchScreenViewController")
    }
    
}

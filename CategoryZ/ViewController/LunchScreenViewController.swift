//
//  LunchScreenViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/16/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LunchScreenViewController: RxHomeBaseViewController<FirstView> {
    
    let viewModel = FirstViewValidViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func subscribe() {
        
        let input = FirstViewValidViewModel.Input(viewdidAppearTrigger: rx.viewDidAppear)
        
        let output = viewModel.transform(input)
            
        output.changeViewController
            .drive(with: self) { owner, bool in
                if bool {
                    
                    // 메인뷰로 루트뷰 변경 해야함
                    //changeRootView(to: <#T##UIViewController#>, isNavi: <#T##Bool#>)
                } else {
                    let viewController = GetStartViewController()
                    
                    let nvc = UINavigationController(rootViewController: viewController)
                    nvc.modalPresentationStyle = .fullScreen
                    owner.present(nvc, animated: true)
                }
            }
            .disposed(by: disPoseBag)
    }
    
    
    
}

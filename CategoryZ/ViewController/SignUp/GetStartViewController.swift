//
//  GetStartViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import UIKit
import RxSwift
import RxCocoa

final class GetStartViewController: RxHomeBaseViewController<GetStartView> {
 
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func subscribe() {
        
        homeView.loginButton.rx
            .tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                print("다음뷰")
                owner.navigationController?.pushViewController(LoginViewController(), animated: true)
            }
            .disposed(by: disPoseBag)
        
        homeView.signUpButton.rx
            .tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                print("pushViewController: UserInfoRegViewController")
                owner.navigationController?.pushViewController(UserInfoRegViewController(), animated: true)
            }
            .disposed(by: disPoseBag)
    }
    
    deinit {
        print("GetStartViewController")
    }
}

//
//  UserInfoRegViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/11/24.
//

import UIKit
import RxSwift
import RxCocoa

final class UserInfoRegViewController: RxHomeBaseViewController<UserInfoRegView> {
    
    
    let viewModel = UserInfoRegisterViewModel()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        loginNavigationSetting()
        
    }

    override func subscribe() {
        rx.viewDidAppear
            .take(1)
            .bind(with: self) { owner, bool in
                if bool == true {
                    owner.homeView.nameTextField.becomeFirstResponder()
                }
            }
            .disposed(by: disPoseBag)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        homeView.nameTextField.becomeFirstResponder()
    }
    override func navigationSetting() {
        navigationItem.title = "가입하기"
    }

}

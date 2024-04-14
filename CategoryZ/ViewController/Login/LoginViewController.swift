//
//  LoginVIewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: RxHomeBaseViewController<LoginView> {
    
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func subscribe() {
        
        let input = LoginViewModel.Input(
            inputEmailText: homeView.emailTextField.rx.text,
            inputPasswordText: homeView.passwordTextFeild.whitePointTextField.rx.text,
            loginButtonTap: homeView.loginButton.rx.tap
        )
        let output = viewModel.transform(input)
        
        // 로그인 버튼 활성화 여부
        output.loginButtonEnabled
            .drive(homeView.loginButton.rx.isEnabled)
            .disposed(by: disPoseBag)
        
        output.loginButtonEnabled
            .drive(with: self) { owner, bool in
                owner.homeView.loginButton.backgroundColor = bool ? .point : .systemGray
            }
            .disposed(by: disPoseBag)
        
        // 로그인 실패
        output.networkError
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .bind { owner, error in
                owner.showAlert(error: error) { _ in
                    print("error")
                    print(error.message)
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disPoseBag)
        
        // 로그인 성공
        output.loginSuccess
            .drive(with: self) { owner, login in
                print(login)
            }
            .disposed(by: disPoseBag)
        
        
    }
}



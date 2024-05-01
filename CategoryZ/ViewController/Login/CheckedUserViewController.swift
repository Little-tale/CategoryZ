//
//  CheackedUserViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

protocol checkUserModelDelegate: AnyObject {
    func checkdUserCurrect(_ bool: Bool)
}

final class CheckedUserViewController: RxHomeBaseViewController<CheckedUserView> {
    
    let viewModel = CheckUserViewModel()
    
    weak var checkUserDelegate: checkUserModelDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.loginButton.setTitle("본인확인", for: .normal)
    }
    
    override func subscribe() {
        
        // input Element
        let emailText = homeView.emailTextField.rx.text
        let passwordText = homeView.passwordTextFeild.whitePointTextField.rx.text
        
        let loginButtonTab = homeView.loginButton.rx.tap
        
        let input = CheckUserViewModel.Input(
            inputEmailText: emailText,
            inputPasswordText: passwordText,
            loginButtonTap: loginButtonTab
        )
        
        let output = viewModel.transform(input)
            
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        output.loginButtonEnabled
            .drive(homeView.loginButton.rx.isEnabled)
            .disposed(by: disPoseBag)
        
        output.loginButtonEnabled
            .drive(with: self) { owner, bool in
                owner.homeView.loginButton.backgroundColor = bool ? JHColor.likeColor : JHColor.darkGray
            }
            .disposed(by: disPoseBag)
        
        output.isUserCurrectTrigger
            .filter({ $0 == true })
            .drive(with: self) { owner, bool in
                owner.checkUserDelegate?.checkdUserCurrect(bool)
                if owner.navigationController != nil {
                    owner.navigationController?.popViewController(animated: true)
                } else {
                    owner.dismiss(animated: true)
                }
            }
            .disposed(by: disPoseBag)
        
        output.isUserCurrectTrigger
            .filter { $0 == false }
            .drive(with: self) { owner, _ in
                owner.view.makeToast(
                    "정보가 불일치 합니다.",
                    duration: 1,
                    position: .center
                )
            }
            .disposed(by: disPoseBag)
    }
    
}

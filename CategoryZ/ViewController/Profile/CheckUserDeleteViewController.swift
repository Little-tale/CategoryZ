//
//  CheckUserDeletViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/30/24.
//
import UIKit
import RxSwift
import RxCocoa

final class CheckUserDeleteViewController: RxHomeBaseViewController<CheckedUserView> {
    
    private
    var viewModel = DeleteUserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func subscribe() {
        
        // input Info
        let emailText = homeView.emailTextField.rx.text
        let passWordText = homeView.passwordTextFeild
            .whitePointTextField.rx.text
        let deleteButtonTap = homeView.loginButton.rx.tap
        
        let userLeaveTrigger = PublishRelay<Void> ()
        
        let input = DeleteUserViewModel.Input(
            inputEmailText: emailText,
            inputPasswordText: passWordText,
            deleteButtonTap: deleteButtonTap,
            userLeaveTrigger: userLeaveTrigger
        )
        
        // output Area
        let output = viewModel.transform(input)
        
        output.loginButtonEnabled
            .drive(with: self) { owner, bool in
                owner.homeView.loginButton.isEnabled = bool
                owner.homeView.loginButton.backgroundColor = bool ? JHColor.warningColor : JHColor.darkGray
            }
            .disposed(by: disPoseBag)
            
        output.networkError
            .bind(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        output.isUserCurrectTrigger
            .filter { $0 == true }
            .drive(with: self) { owner, _ in
                owner.showAlert(
                    title: "유저 정보 삭제",
                    message: "정말... 떠나실 건가요..?\n떠나시면 복구하실수 없어요...!",
                    actionTitle: "삭제",
                    complite: { _ in
                        userLeaveTrigger.accept(())
                    },
                    .default
                )
            }
            .disposed(by: disPoseBag)
        
        output.successDeleteTrigger
            .drive(with: self) { owner, _ in
                owner.changeRootView(to: LunchScreenViewController(), isNavi: true)
            }
            .disposed(by: disPoseBag)
    }
}


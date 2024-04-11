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
    // 오늘 키워드 : 핫 옵저버블 콜드 옵저버블
    override func subscribe() {
        let publishName = BehaviorRelay<String> (value: "")
        let publishEmail = BehaviorRelay<String> (value: "")
        let publishPassWord = BehaviorRelay<String> (value: "")
        let publishPhoneNum = BehaviorRelay<String?> (value: nil)
        let emailButtonTap = homeView.emailValidTextButton.rx.tap
        let SignUpButtonTap = homeView.successButton.rx.tap
        
        let input = UserInfoRegisterViewModel.Input(
            inputName: publishName,
            inputEmail: publishEmail,
            inputPassword: publishPassWord,
            inputPhoneNum: publishPhoneNum,
            inputButtonTab: SignUpButtonTap,
            inputEmailButtonTap: emailButtonTap
        )
        
        let output = viewModel.transform(input)
        
        // 이메일 형식 검사
        output.emailValid
            .drive(with: self) { owner, valid in
                owner.emailTextFieldValid(owner.homeView.emailTextField, valid)
            }
            .disposed(by: disPoseBag)
    
        // 이름 형식 검사
        output.nameValid
            .drive(with: self) { owner, valid in
                owner.textFieldValidText(owner.homeView.nameTextField, valid)
            }
            .disposed(by: disPoseBag)
        
        // 비밀번호 형식 검사
        output.passwordValid
            .drive(with: self) { owner, valid in
                owner.textFieldValidText(owner.homeView.passWordTextField, valid)
            }
            .disposed(by: disPoseBag)
        
        // 폰 형식 검사
        output.phoneValid
            .drive(with: self) { owner, valid in
                owner.textFieldValidText(owner.homeView.phoneNumberTextField, valid)
            }
            .disposed(by: disPoseBag)
        
        // 버튼 결과 반영
        output.buttonValid.drive(with: self) { owner, bool in
            owner.homeView
                .successButton
                .backgroundColor = bool ? .point : .systemGray
        }
        .disposed(by: disPoseBag)
        
        // 통신후 가입 여부
        output.signUpSuccess
            .drive(with: self) { owner, model in
                let title = model.nick + "님"
                owner.showAlert(title: title, message: "가입을 축하드립니다!") { _ in
                    let nav = UINavigationController(rootViewController: GetStartViewController())
                    owner.changeRootView(to: nav)
                }
            }
            .disposed(by: disPoseBag)
        // 통신후 가입 실패시
        output.signUPFail
            .drive(with: self) { owner, error in
                owner.showAlert(title: "Error",message: error.message) { _ in
                }
            }
            .disposed(by: disPoseBag)
        
        output.emailDuplicateValid
            .drive(with: self) { owner, valid in
                switch valid {
                case .isEmpty, .minCount, .noMatch:
                    owner.homeView.emailTextField.placeholder = "이메일이 중복이에요!"
                    owner.homeView.emailTextField.borderActiveColor = .point
                    owner.viewModel.emailFlag = false
                case.match :
                    owner.homeView.emailTextField.placeholderColor = .textBlack
                    owner.homeView.emailTextField.placeholder = "좋은 이메일 이네요!"
                    owner.homeView.emailTextField.borderActiveColor = .pointGreen
                    owner.viewModel.emailFlag = true
                }
            }
            .disposed(by: disPoseBag)
        
        // 이메일 중복 검사 버튼 활성화 여부
        output.emailButtonEnabled
            .compactMap({ $0 })
            .drive(with: self) { owner, bool in
                let color: UIColor = bool ? .point : .systemGray2
                owner.homeView.emailValidTextButton.setTitleColor(color, for: .normal)
                owner.homeView.emailValidTextButton.isEnabled = bool
            }
            .disposed(by: disPoseBag)
        
        // 뷰가 다나오고 나서 키보드 올리기
        rx.viewDidAppear
            .take(1)
            .bind(with: self) { owner, bool in
                if bool == true {
                    owner.homeView.nameTextField.becomeFirstResponder()
                }
            }
            .disposed(by: disPoseBag)
        
        homeView.nameTextField.rx
            .text
            .orEmpty
            .bind(to: publishName)
            .disposed(by: disPoseBag)
        
        homeView.emailTextField.rx
            .text
            .orEmpty
            .bind(to: publishEmail)
            .disposed(by: disPoseBag)
        
        homeView.passWordTextField.rx
            .text
            .orEmpty
            .bind(to: publishPassWord)
            .disposed(by: disPoseBag)
        
        homeView.phoneNumberTextField.rx
            .text
            .orEmpty
            .bind(to: publishPhoneNum)
            .disposed(by: disPoseBag)
        
        // 비밀번호 보안 활성화 여부
        homeView.passwordHiddenButton.rx.tap.bind(with: self) { owner, _ in
            let bool = owner.homeView.passWordTextField.isSecureTextEntry
            owner.homeView.passWordTextField.isSecureTextEntry = !bool
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

    private func textFieldValidText(_ textFiled: WhitePointTextField, _ valid: textValidation) {
        textFiled.borderActiveColor = .point
        switch valid {
        case .isEmpty:
            textFiled.placeholderColor = .systemGray
            textFiled.setDefaultPlaceHolder()
            break
        case .minCount:
            textFiled.placeholderColor = .point
            textFiled.placeholder = "글자수가 부족해요!"
        case .match:
            textFiled.placeholder = ""
            textFiled.borderActiveColor = JHColor.currect
        case .noMatch:
            textFiled.placeholderColor = .point
            textFiled.placeholder = "양식에 맞지 않아요!"
        }
    }
    
    private func emailTextFieldValid(_ textFiled: WhitePointTextField, _ valid: textValidation) {
        switch valid {
        case .isEmpty:
            textFiled.placeholderColor = .systemGray
            textFiled.setDefaultPlaceHolder()
        case .minCount:
            textFiled.placeholderColor = .point
            textFiled.placeholder = "글자수가 부족해요!"
        case .match:
            if !viewModel.emailFlag {
                textFiled.placeholder = "중복 검사가 필요해요!"
                textFiled.borderActiveColor = .blue
            }
        case .noMatch:
            viewModel.emailFlag = false
            textFiled.placeholderColor = .point
            textFiled.placeholder = "양식에 맞지 않아요!"
        }
    }
    
}

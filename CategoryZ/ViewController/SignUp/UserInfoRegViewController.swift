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
        
        let successCliked = PublishRelay<Void> ()
        
        let input = UserInfoRegisterViewModel
            .Input(
                inputName: homeView.nameTextField.rx.text,
                inputEmail: homeView.emailTextField.rx.text,
                inputPassword: homeView.passWordTextField.rx.text,
                inputPhoneNum: homeView.phoneNumberTextField.rx.text,
                inputButtonTab: homeView.successButton.rx.tap,
                inputEmailButtonTap: homeView.emailValidTextButton.rx.tap,
                successCliked: successCliked
            )
        
        let output = viewModel.transform(input)
        
        // email 검사 결과 반영
        output.emailValid
            .drive(with: self) { owner, valid in
                owner.emailTextFieldValid(owner.homeView.emailTextField, valid)
            }
            .disposed(by: disPoseBag)
        
        // 전화번호 검사 결과 UI반영
        output.phoneValid
            .drive(with: self) { owner, valid in
                owner.textFieldValidText(owner.homeView.phoneNumberTextField, valid)
            }
            .disposed(by: disPoseBag)
        
        // 비밀번호 검사 결과 UI반영
        output.passwordValid
            .drive(with: self) { owner, valid in
                owner.textFieldValidText(owner.homeView.passWordTextField, valid)
            }
            .disposed(by: disPoseBag)
        
        // 이름 검사 결과 UI반영
        output.nameValid
            .drive(with: self) { owner, valid in
                owner.textFieldValidText(owner.homeView.nameTextField, valid)
            }
            .disposed(by: disPoseBag)
        
        // 버튼 탭 활성화 여부
        output.buttonEnabled
            .drive(with: self) { owner, bool in
                print("버튼 탭 활성화 여부 : \(bool)")
                owner.homeView.successButton.isEnabled = bool
                owner.homeView.successButton.backgroundColor = bool ? .point : .systemGray3
            }
            .disposed(by: disPoseBag)
        
        // 가입 성공했을시
        output.networkForSignUpSuccess
            .bind(with: self) { owner, name in
                owner.showAlert(title: name + "님", message: "가입을 축하 드립니다.") { _ in
                    // 가입 성공 버튼 클릭시
                    // 바로 로그인 하여 다음 뷰로 넘어가도록 하기
                    successCliked.accept(())
                }
            }
            .disposed(by: disPoseBag)
        
        // 이메일 중복검사 통과시
        output.networkForEmailSuccess
            .bind(with: self) { owner, message in
                owner.showAlert(title: "성공!",message: message) { _ in
                }
            }
            .disposed(by: disPoseBag)
        
        
        // 뷰가 나왔을떄 키보드
        rx.viewDidAppear
            .take(1)
            .bind(with: self) { owner, bool in
                owner.homeView.nameTextField.becomeFirstResponder()
            }
            .disposed(by: disPoseBag)
        
        // 각 에러에 대한 에러 처리
        output.networkError
            .debounce(.microseconds(200), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, error in
                if error.errorCode == 409 {
                    owner.showAlert(title: "경고",message: error.message) { _ in
                    }
                }else {
                    owner.showAlert(title: "오류",message: "재시도 바랍니다.") { _ in
                    }
                }
            }
            .disposed(by: disPoseBag)
        
        output.finalFailTrigger
            .drive(with: self) { owner, _ in
                owner.changeRootView(to: LunchScreenViewController(), isNavi: true)
            }
            .disposed(by: disPoseBag)
        
        
        successCliked
            .withLatestFrom(output.finalSuccesTrigger)
            .bind(with: self) { owner, _ in
                owner.changeRootView(to: CategoryZTabbarController(), isNavi: false)
            }
            .disposed(by: disPoseBag)
        
    }
    
    override func navigationSetting() {
        navigationItem.title = "가입하기"
    }
    
    private
    func textFieldValidText(_ textFiled: WhitePointTextField, _ valid: textValidation) {
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
    
    private
    func emailTextFieldValid(_ textFiled: WhitePointTextField, _ valid: EmailTextValid) {
        switch valid {
        case .isEmpty:
            textFiled.borderActiveColor = .point
            textFiled.placeholderColor = .systemGray
            textFiled.setDefaultPlaceHolder()
        case .minCount:
            textFiled.borderActiveColor = .point
            textFiled.placeholderColor = .point
            textFiled.placeholder = "글자수가 부족해요!"
        case .match:
            textFiled.placeholderColor = .point
            textFiled.placeholder = "중복 검사가 필요해요!"
            textFiled.borderActiveColor = .blue
        case .noMatch:
            textFiled.borderActiveColor = .point
            textFiled.placeholderColor = .point
            textFiled.placeholder = "양식에 맞지 않아요!"
        case .validCurrect:
            textFiled.borderActiveColor = .green
            textFiled.placeholderColor = .green
            textFiled.placeholder = "좋은 이메일 이에요!"
        case .duplite:
            textFiled.borderActiveColor = .point
            textFiled.placeholderColor = .point
            textFiled.placeholder = "중복된 이메일 입니다."
        }
    }
    
}


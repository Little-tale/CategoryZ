//
//  UserInfoRegisterViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/11/24.
//

import Foundation
import RxSwift
import RxCocoa

final class UserInfoRegisterViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    let textValid = TextValid()

    struct Input {
        let inputName : ControlProperty<String?>
        let inputEmail : ControlProperty<String?>
        let inputPassword : ControlProperty<String?>
        let inputPhoneNum : ControlProperty<String?>
        let inputButtonTab: ControlEvent<Void>
        let inputEmailButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        // 이름 검사 결과들
        let nameValid: Driver<textValidation>
        // 이메일 검사 결과들
        let emailValid: Driver<EmailTextValid>
        // 비밀번호 검사 결과들
        let passwordValid: Driver<textValidation>
        // 전화번호 검사 결과들
        let phoneValid: Driver<textValidation>
        // 회원가입 활성화 여부
        let buttonEnabled: Driver<Bool>
        // 이메일 버튼 활성화 여부
        let emailButtonEnabled : Driver<Bool>
        // 네트워크 에러 (에러코드를 통행 이메일 중복인지 아닌지와 회원가입 실패 여부)
        let networkError: PublishRelay<NetworkError>
        // 네트워크를 통한 이메일 중복 검사 성공
        let networkForEmailSuccess: PublishRelay<String>
        // 네트워크를 통해 회원가입 성공
        let networkForSignUpSuccess: PublishRelay<String>
    }
    
    func transform(_ input: Input) -> Output {
        // 이메일에 대한 성공
        let networkForEmailSuccess = PublishRelay<String>()
        // 가입에 대한 성공
        let networkForSignUpSuccess = PublishRelay<String>()
        // 이메일 버튼 활성화 여부
        let emailButtonEnabled = PublishRelay<Bool> ()
        // 네트워크 에러 처리
        let networkError = PublishRelay<NetworkError> ()
        // 이메일 검사 종합 결과 UI 반영
        let emailValidTest = BehaviorRelay<EmailTextValid> (value: .isEmpty)
        
        
        
        // 이메일 텍스트 input
       let emailText = input.inputEmail.orEmpty
            .distinctUntilChanged()
            .share()
        
        // 이메일 검사 (네트워크 제외) 결과
        emailText
            .withUnretained(self)
            .map { owner, text in
                let valid = owner.textValid.EmailTextValid(text)
                return valid
            }
            .bind { valid in
                emailValidTest.accept(valid)
            }
            .disposed(by: disposeBag)
            //.asDriver(onErrorJustReturn: .isEmpty)
        
        // 이메일 중복 버튼 클릭시 결과
        input.inputEmailButtonTap
            .withLatestFrom(emailText)
            .map { EmailValidationQuery(email: $0) }
            .flatMapLatest {
                NetworkManager.fetchNetwork(model: EmailVaildModel.self, router: .emailVaild(query: $0))
            }
            .bind(with: self) { owenr, result in
                    switch result {
                    case .success(let query):
                        emailValidTest.accept(.validCurrect)
                        networkForEmailSuccess.accept(query.message)
                    case .failure(let error):
                        networkError.accept(error)
                        emailValidTest.accept(.duplite)
                    }
            }
            .disposed(by: disposeBag)
            
        // 닉네임 검사 결과 Driver
        let nameValid = input.inputName.orEmpty
            .withUnretained(self)
            .map { owner, text in
                owner.textValid.nickNameVaild(text)
            }
            .asDriver(onErrorJustReturn: .isEmpty)
        
        // 비밀번호 검사 결과 Driver
        let passwordValid = input.inputPassword.orEmpty
            .withUnretained(self)
            .map { owner, text in
                owner.textValid.passwordVaild(text)
            }
            .asDriver(onErrorJustReturn: .isEmpty)
        
        // 전화번호 검사 결과 Driver
        let phoneValid = input.inputPhoneNum.orEmpty
            .withUnretained(self)
            .map { owner, text in
                owner.textValid.phoneNumberValid(text)
            }
            .asDriver(onErrorJustReturn: .isEmpty)
        
        // 이메일을 제외한 드라이버 콤바인 결과 Bool
        let combineObservable = Driver.combineLatest(nameValid, passwordValid, phoneValid) { name, password, phone in
            return name == textValidation.match && password == textValidation.match && phone == textValidation.match
        }.asObservable()
        
        // 회원가입 버튼 활성화 여부
        let signUpButtonEnabled = Observable
            .combineLatest(emailValidTest, combineObservable)
            .map { email, other in
                if email == .validCurrect && other == true {
                    return true
                }else {
                    return false
                }
            }
            .asDriver(onErrorJustReturn: false)
        
        // 전체 텍스트 묶어주기
        let combineText = Observable.combineLatest(
            input.inputName.orEmpty,
            input.inputPassword.orEmpty,
            input.inputEmail.orEmpty,
            input.inputPhoneNum.orEmpty
        )
            .map { combine in
                return (name: combine.0,
                        password: combine.1,
                        email: combine.2,
                        phoneNum: combine.3
                )
            }
       // 가입 버튼 클릭시
        input.inputButtonTab
            .withLatestFrom(combineText)
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { JoinQuery(email: $0.email, password: $0.password, nick: $0.name, phoneNum: $0.phoneNum) }
            .flatMapLatest { NetworkManager.fetchNetwork(model: JoinModel.self, router: .join(query: $0)) }
            .asObservable()
            .bind { result in
                switch result {
                case .success(let success):
                    networkForSignUpSuccess.accept(success.nick)
                case .failure(let fail):
                    networkError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
            
    
        return Output(
            nameValid: nameValid,
            emailValid: emailValidTest.asDriver(onErrorJustReturn: .isEmpty),
            passwordValid: passwordValid,
            phoneValid: phoneValid,
            buttonEnabled: signUpButtonEnabled,
            emailButtonEnabled: emailButtonEnabled.asDriver(onErrorJustReturn: false),
            networkError: networkError,
            networkForEmailSuccess: networkForEmailSuccess,
            networkForSignUpSuccess: networkForSignUpSuccess
        )
    }
}



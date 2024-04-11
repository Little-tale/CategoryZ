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
    
    var emailFlag = false
    
    struct Input {
        let inputName : BehaviorRelay<String>
        let inputEmail : BehaviorRelay<String>
        let inputPassword : BehaviorRelay<String>
        let inputPhoneNum : BehaviorRelay<String?>
        let inputButtonTab: ControlEvent<Void>
        let inputEmailButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let nameValid : Driver<textValidation>
        let emailValid : Driver<textValidation>
        let passwordValid : Driver<textValidation>
        let phoneValid : Driver<textValidation>
        let buttonValid : Driver<Bool>
        
        let signUpSuccess: Driver<JoinModel>
        let signUPFail: Driver<NetworkError>
        let emailDuplicateValid: Driver<textValidation>
        let emailButtonEnabled: Driver<Bool?>
    }
    
    func transform(_ input: Input) -> Output {
        
        let networkSuccessRelay = PublishRelay<JoinModel>()
        let networkFailureRelay = PublishRelay<NetworkError>()
        let emailButtonEnabled = PublishRelay<Bool?> ()
       
        
        let combined = Observable.combineLatest(
            input.inputEmail,
            input.inputName,
            input.inputPassword,
            input.inputPhoneNum
        )
            .map { combine in
                return (email: combine.0, name: combine.1, password: combine.2, phoneNum: combine.3)
            }
        
        let emailDriver = input.inputEmail
            .withUnretained(self)
            .map {
                owner, text in
                let vaild = owner.textValid.EmailTextValid(text)
                if vaild == .match {
                    emailButtonEnabled.accept(true)
                }else {
                    emailButtonEnabled.accept(false)
                }
                return vaild
            }
            .asDriver(onErrorJustReturn: .noMatch)
        
            //.asDriver(onErrorJustReturn: false)
        let nickNameDriver = input.inputName
            .withUnretained(self)
            .map { owner, text in
                return owner.textValid.nickNameVaild(text)
            }
            .asDriver(onErrorJustReturn: .noMatch)
        
        let passwordDriver = input.inputPassword
            .withUnretained(self)
            .map { owner, text in
                return owner.textValid.passwordVaild(text)
            }
            .asDriver(onErrorJustReturn: .noMatch)
        
        let phoneDriver = input.inputPhoneNum
            .withUnretained(self)
            .filter({ $0.1 != nil })
            .map { owner, text in
                return owner.textValid.phoneNumberValid(text!)
            }
            .asDriver(onErrorJustReturn: .minCount)
        
        let emailValid = input.inputEmailButtonTap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .withLatestFrom(input.inputName)
            .map { string in
                return EmailValidationQuery(email: string)
            }
            .flatMapLatest { query in
                return NetworkManager.fetchNetwork(model: EmailVaildModel.self, router: .emailVaild(query: query))
            }
            .compactMap { result in
                switch result {
                case .success(_):
                    return textValidation.match
                case .failure(let fail):
                    print(fail.message)
                    return textValidation.noMatch
                }
            }
            .asDriver(onErrorDriveWith: .never())
            
        
        
  
        let buttonValid = Driver.combineLatest(
            emailDriver,
            nickNameDriver,
            passwordDriver,
            phoneDriver,
            emailValid
        ) { email, nickName, passWord, phone, emailValid in
            return email == textValidation.match &&
            nickName == textValidation.match &&
            passWord == textValidation.match &&
            (phone == textValidation.match || phone == textValidation.isEmpty) && emailValid == textValidation.match
        }
        
        input.inputButtonTab
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance )
            .flatMapLatest { _ in
                return combined
                    .take(1)
                    .map { JoinQuery(email: $0.email, password: $0.password, nick: $0.name, phoneNum: $0.phoneNum) }
                    .flatMapLatest { query in
                        NetworkManager.fetchNetwork(model: JoinModel.self, router: .join(query: query))
                    }
            }
            .bind { result in
                switch result {
                case .success(let success):
                    networkSuccessRelay.accept(success)
                case .failure(let failuer):
                    networkFailureRelay.accept(failuer)
                }
            }
            .disposed(by: disposeBag)
            

        
        return Output(
            nameValid: nickNameDriver,
            emailValid: emailDriver,
            passwordValid: passwordDriver,
            phoneValid: phoneDriver,
            buttonValid: buttonValid,
            signUpSuccess: networkSuccessRelay.asDriver(onErrorDriveWith: .never()),
            signUPFail: networkFailureRelay.asDriver(onErrorDriveWith: .never()),
            emailDuplicateValid: emailValid,
            emailButtonEnabled: emailButtonEnabled.asDriver(onErrorJustReturn: false)
        )
    }
    
    private func checkEmail(_ string: String) {
        
    }

}

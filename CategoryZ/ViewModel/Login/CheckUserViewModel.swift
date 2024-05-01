//
//  CheckUserViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa


final class CheckUserViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private
    let userId = UserIDStorage.shared.userID
    
    struct Input {
        let inputEmailText: ControlProperty<String?>
        let inputPasswordText: ControlProperty<String?>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let loginButtonEnabled: Driver<Bool>
        let isUserCurrectTrigger: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        // output
        let networkError = PublishRelay<NetworkError>()
        
        let loginSuccess = PublishRelay<LoginModel> ()
        
        let isUserCureectTrigger = PublishRelay<Bool> ()
        
        let loginButtonEnabled = BehaviorRelay(value: false)
        
        
        let loginTextCombine = Observable.combineLatest(
            input.inputEmailText.orEmpty,
            input.inputPasswordText.orEmpty
        )
        
        loginTextCombine
            .map { combine in
                return combine.0.count > 3 && combine.1.count > 4
            }
            .bind { bool in
                loginButtonEnabled.accept(bool)
            }
            .disposed(by: disposeBag)
        
        input.loginButtonTap
            .withLatestFrom(loginTextCombine)
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { combine in
                return (email: combine.0, password: combine.1)
            }
            .map({ combine in
                LoginQuery(email: combine.email, password: combine.password)
            })
            .flatMapLatest { loginQuery in
                NetworkManager.fetchNetwork(model: LoginModel.self, router: .authentication(.login(query: loginQuery)))
            }
            .bind { result in
                switch result {
                case .success(let model):
                    loginSuccess.accept(model)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        loginSuccess
            .bind(with: self) { owner, model in
                if let userId = owner.userId {
                    let bool = model.user_id == userId
                    isUserCureectTrigger.accept(bool)
                } else {
                    networkError.accept(.loginError(statusCode: 419, description: "유저 정보를 찾을수 없습니다."))
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            networkError: networkError.asDriver(onErrorJustReturn: .loginError(statusCode: 419 , description: "")),
            loginButtonEnabled: loginButtonEnabled.asDriver(),
            isUserCurrectTrigger: isUserCureectTrigger.asDriver(onErrorDriveWith: .never())
        )
    }
    
}

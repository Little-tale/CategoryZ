//
//  LoginViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input{
        let inputEmailText: ControlProperty<String?>
        let inputPasswordText: ControlProperty<String?>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output{
        let networkError: PublishRelay<NetworkError>
        let loginSuccess: Driver<LoginModel>
        let loginButtonEnabled: Driver<Bool>
    }
    
    
    func transform(_ input: Input) -> Output {
        
        let networkError = PublishRelay<NetworkError>()
        let loginSuccess = PublishRelay<LoginModel> ()
        let loginButtonEnabled = BehaviorRelay(value: false)
        
        let loginTextCombine = Observable.combineLatest(
            input.inputEmailText.orEmpty,
            input.inputPasswordText.orEmpty
        )
            .share()
        
        loginTextCombine
            .map { combine in
                return combine.0.count > 3 && combine.1.count > 4
            }
            .bind { bool in
                loginButtonEnabled.accept(bool)
            }
            .disposed(by: disposeBag)
            
        // 로그인 버튼 탭
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
                case .success(let loginModel):
                    UserIDStorage.shared.userID = loginModel.user_id
                    
                    TokenStorage.shared.accessToken = loginModel.accessToken
                    
                    TokenStorage.shared.refreshToken = loginModel.refreshToken
                    
                    loginSuccess.accept(loginModel)
                case .failure(let fail):
                    networkError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
     
        return Output(
            networkError: networkError,
            loginSuccess: loginSuccess.asDriver(
                onErrorDriveWith: .never()),
            loginButtonEnabled: loginButtonEnabled.asDriver()
        )
    }
    
}

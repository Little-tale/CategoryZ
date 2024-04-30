//
//  DeleteUserViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/30/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DeleteUserViewModel: RxViewModelType {
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private
    let userId = UserIDStorage.shared.userID
    
    struct Input {
        let inputEmailText: ControlProperty<String?>
        let inputPasswordText: ControlProperty<String?>
        let deleteButtonTap: ControlEvent<Void>
        let userLeaveTrigger: PublishRelay<Void>
    }
    
    struct Output {
        let networkError: PublishRelay<NetworkError>
        let loginButtonEnabled: Driver<Bool>
        let isUserCurrectTrigger: Driver<Bool>
        let successDeleteTrigger: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        let networkError = PublishRelay<NetworkError>()
        let loginSuccess = PublishRelay<LoginModel> ()
        let loginButtonEnabled = BehaviorRelay(value: false)
        
        let isUserCureectTrigger = PublishRelay<Bool> ()
        let successDeleteTrigger = PublishRelay<Void> ()
        
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
        
        // 로그인 버튼 탭
        input.deleteButtonTap
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
        
        // 로그인 성공시 현재 계정의 아이디와 비교합니다.
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
        
        // 유저가 떠남을 최종 결정했을때
        input.userLeaveTrigger
            .flatMapLatest { _ in
                NetworkManager.noneModelRequest(router: .authentication(.userWithDraw))
            }
            .bind { result in
                switch result {
                case .success:
                    successDeleteTrigger.accept(())
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            networkError: networkError,
            loginButtonEnabled: loginButtonEnabled.asDriver(),
            isUserCurrectTrigger: isUserCureectTrigger.asDriver(onErrorDriveWith: .never()),
            successDeleteTrigger: successDeleteTrigger.asDriver(onErrorDriveWith: .never())
        )
    }
}

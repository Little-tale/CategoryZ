//
//  FirstViewValid.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/16/24.
//

import Foundation
import RxSwift
import RxCocoa


final class FirstViewValidViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        
    }
    
    struct Output {
        let changeViewController: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let publish = PublishRelay<Bool> ()
        // let networkError = PublishRelay<NetworkError> ()
        
        if let accessToken = TokenStorage.shared.accessToken,
           let refreshToken = TokenStorage.shared.refreshToken {
            
            NetworkManager
                .fetchNetwork(model: RefreshModel.self,
                              router: .authentication(
                                .refreshTokken(access: accessToken,
                                               Refresh: refreshToken)
                              )
                )
                .subscribe(with: self, onSuccess: { owner, result in
                    switch result {
                    case .success(let tokenResult):
                        TokenStorage.shared.accessToken = tokenResult.accessToken
                        publish.accept(true) // 재 리프레시 성공시
                    case .failure:
                        publish.accept(false)
                    }
                })
                .disposed(by: disposeBag)
        } else {
            publish.accept(false)
        }
        
        return Output(changeViewController: publish.asDriver(onErrorDriveWith: .never()))
    }
}

//
//  FirstViewValidViewMOdel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa


final class FirstViewValidViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let viewdidAppearTrigger: ControlEvent<Bool>
    }
    
    struct Output {
        let changeViewController: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let publish = PublishRelay<Bool> ()
        // let networkError = PublishRelay<NetworkError> ()
        let refreshModel = PublishRelay<(access:String, refresh: String)> ()
        
        input.viewdidAppearTrigger
            .take(1)
            .bind { _ in
                guard let accessToken = TokenStorage.shared.accessToken,
                      let refreshToken = TokenStorage.shared.refreshToken else {
                    
                    publish.accept(false)
                    return
                }
                refreshModel.accept((accessToken,refreshToken))
            }
            .disposed(by: disposeBag)
        
        
        refreshModel
            .flatMap({ access, refresh in
                NetworkManager
                    .fetchNetwork(model: RefreshModel.self,
                                  router: .authentication(
                                    .refreshTokken(access: access,
                                                   Refresh: refresh)
                                  )
                    )
            })
            .bind(onNext: { result in
                switch result{
                case .success(let newAccess):
                    TokenStorage.shared.accessToken = newAccess.accessToken
                    publish.accept(true)
                case .failure:
                    publish.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        
        return Output(changeViewController: publish.asDriver(onErrorDriveWith: .never()))
    }
}


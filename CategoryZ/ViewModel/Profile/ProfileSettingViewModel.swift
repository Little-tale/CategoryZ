//
//  ProfileSettingViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/22/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileSettingViewModel: RxViewModelType {
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private
    let repository = RealmRepository()
    
    struct Input {
        let viewWiddTrigger : Observable<Void>
        let logoutTrigger: PublishRelay<Void>
    }
    
    struct Output {
        let outputNetwork: Driver<NetworkError>
        let successModel: Driver<ProfileModel>
        let logoutSuccessTrigger: PublishRelay<Void>
    }
    
    func transform(_ input: Input) -> Output {
        
        let publishModel = PublishSubject<ProfileModel> ()
        let netwrokError = PublishSubject<NetworkError> ()
        let logoutSuccessTrigger = PublishRelay<Void> ()
        
        input.viewWiddTrigger
            .flatMapLatest { _ in
                return NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.profileMeRead))
            }
            .bind { result in
                switch result {
                case .success(let profileModel):
                    publishModel.onNext(profileModel)
                case .failure(let fail):
                    netwrokError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        input.logoutTrigger
            .bind(with: self) { owner, _ in
                UserIDStorage.shared.userID = nil
                TokenStorage.shared.accessToken = nil
                TokenStorage.shared.refreshToken = nil
                owner.repository.deleteAll()
                logoutSuccessTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(
            outputNetwork: netwrokError.asDriver(onErrorDriveWith: .never()),
            successModel: publishModel.asDriver(onErrorDriveWith: .never()),
            logoutSuccessTrigger: logoutSuccessTrigger
        )
    }
    
}

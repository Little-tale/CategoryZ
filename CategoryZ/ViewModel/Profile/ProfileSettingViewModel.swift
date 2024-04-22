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
    
    struct Input {
        let viewWiddTrigger : Observable<Void>
    }
    
    struct Output {
        let outputNetwork: Driver<NetworkError>
        let successModel: Driver<ProfileModel>
    }
    
    func transform(_ input: Input) -> Output {
        
        let publishModel = PublishSubject<ProfileModel> ()
        let netwrokError = PublishSubject<NetworkError> ()
        
        input.viewWiddTrigger
            .flatMapLatest { _ in
                return NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.profileMeRead))
            }
            .bind { result in
                switch result{
                case .success(let profileModel):
                    publishModel.onNext(profileModel)
                case .failure(let fail):
                    netwrokError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        return Output(
            outputNetwork: netwrokError.asDriver(onErrorDriveWith: .never()),
            successModel: publishModel.asDriver(onErrorDriveWith: .never())
        )
    }
    
}

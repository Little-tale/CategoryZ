//
//  UserProfileViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa


final class UserProfileViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let inputProfileType: BehaviorRelay<ProfileType>
    }
    
    struct Output {
        let outputProfile : Driver<ProfileModel>
        let networkError : Driver<NetworkError>
    }
    
    func transform(_ input: Input) -> Output {
        
        let networkError = PublishSubject<NetworkError> ()
        let outputProfile = PublishSubject<ProfileModel> ()
        
        let shareUserId = input.inputProfileType
            .share()
        
        shareUserId.flatMapLatest { profileType in
            switch profileType {
            case .me:
                NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.profileMeRead))
            case .other(let otherUserId):
                NetworkManager.fetchNetwork(model: ProfileModel.self, router:.profile(.otherUserProfileRead(userId: otherUserId)) )
            }
        }
        .bind { result in
            switch result {
            case .success(let profile):
                outputProfile.onNext(profile)
            case .failure(let error):
                networkError.onNext(error)
            }
        }
        .disposed(by: disposeBag)
        
        
        return .init(
            outputProfile: outputProfile.asDriver(onErrorDriveWith: .never()),
            networkError: networkError.asDriver(
                onErrorDriveWith: .never()
            )
        )
    }
    
}

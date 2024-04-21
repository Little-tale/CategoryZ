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
        let postReadMainModel: Driver<PostReadMainModel>
    }
    
    func transform(_ input: Input) -> Output {
        let limit = "10"
        let nextCursor: String? = nil
        
        let networkError = PublishSubject<NetworkError> ()
        let outputProfile = PublishSubject<ProfileModel> ()
        let postReadMainModel = PublishSubject<PostReadMainModel> ()
        
        let shareUserId = input.inputProfileType
            .share()
        
        /// 프로필 조회 API
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
        
        shareUserId
            .flatMapLatest { profileType in
                switch profileType {
                case .me:
                    NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.postRead(next: nextCursor, limit: limit, productId: nil)))
                case .other(let otherUserId):
                    NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.postRead(next: nextCursor, limit: limit, productId: nil)))
                }
            }
            .bind { result in
                switch result {
                case .success(let datas):
                    postReadMainModel.onNext(datas)
                case .failure(let fail):
                    networkError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        return .init(
            outputProfile: outputProfile.asDriver(onErrorDriveWith: .never()),
            networkError: networkError.asDriver(
                onErrorDriveWith: .never()
            ), postReadMainModel: postReadMainModel.asDriver(
                onErrorDriveWith: .never())
        )
    }
    
}

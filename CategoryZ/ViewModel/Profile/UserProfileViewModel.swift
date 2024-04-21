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
    
    private
    var userId: String? = UserIDStorage.shared.userID
    
    private
    var realModel: [SNSDataModel] = []
    
    struct Input {
        let inputProfileType: BehaviorRelay<ProfileType>
    }
    
    struct Output {
        let outputProfile : Driver<ProfileModel>
        let networkError : Driver<NetworkError>
        let postReadMainModel: Driver<[SNSDataModel]>
    }
    
    func transform(_ input: Input) -> Output {
        let limit = "10"
        let nextCursor: String? = nil
        
        let networkError = PublishSubject<NetworkError> ()
        let outputProfile = PublishSubject<ProfileModel> ()
        let postReadMainModel = PublishSubject<[SNSDataModel]> ()
        
      
        
        /// 프로필 조회 API
        input.inputProfileType.flatMapLatest { profileType in
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
        
        input.inputProfileType
            .withUnretained(self)
            .map { owner, profileId in
                switch profileId {
                case .me:
                    return owner.userId
                case .other(let otherUserId):
                    return otherUserId
                }
            }
            .filter { $0 != nil }
            .flatMapLatest { userId in
                NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.userCasePostRead(userId: userId!, next: nextCursor, limit: limit, productId: nil)))
            }
            .bind(with: self) {owner, result in
                switch result {
                case .success(let model):
                    owner.realModel = model.data
                    postReadMainModel.onNext(owner.realModel)
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

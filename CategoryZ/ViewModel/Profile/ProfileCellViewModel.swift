//
//  ProfileCellViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileCellViewModel: RxViewModelType {
    
    var disposeBag: DisposeBag = .init()
    
    struct Input {
        let inputProfileType: BehaviorRelay<ProfileType>
        let leftButtonTap: ControlEvent<Void>
        let inputUserId: String?
    }
    
    struct Output {
        let outputProfile : Driver<ProfileModel>
        let networkError: PublishRelay<NetworkError>
        let followState: Driver<Bool>
        // let outputReloadTrigger: PublishRelay<Void>
    }
    
    func transform(_ input: Input) -> Output {
        var otherId: String? = nil
        let outputProfile = PublishSubject<ProfileModel> ()
            
        let networkError = PublishRelay<NetworkError> ()
        
        let currenFollowing = BehaviorRelay<Bool> (value: false)
        
        let outputReloadTrigger = PublishRelay<Void> ()
        
        
        
        /// 프로필 조회 API
        input.inputProfileType
            .flatMapLatest { profileType in
            switch profileType {
            case .me:
               return  NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.profileMeRead))
            case .other(let otherUserId):
                otherId = otherUserId
                return NetworkManager.fetchNetwork(model: ProfileModel.self, router:.profile(.otherUserProfileRead(userId: otherUserId)) )
            }
        }
        .bind { result in
            switch result {
            case .success(let profile):
                print("완전 시작 팔로워들 : ",profile.followers.map({ $0.userID }))
                outputProfile.onNext(profile)
            case .failure(let error):
                networkError.accept(error)
            }
        }
        .disposed(by: disposeBag)
        
        
        
        let isFollowing = outputProfile
            .withLatestFrom(input.inputProfileType) { profile, type -> Bool in
                guard case .other = type else { return false }
                guard let userId = input.inputUserId else {
                    networkError.accept(.loginError(statusCode: 419, description: "로그인 에러"))
                    return false
                }
                return profile.followers.contains { $0.userID == userId }
            }
            .do(onNext: currenFollowing.accept)
            .asDriver(onErrorJustReturn: false)
            
        
        input.leftButtonTap
            .withLatestFrom(isFollowing)
            .filter({ _ in
                otherId != nil
            })
            .flatMapLatest { isFollowing in
                let userId = otherId!
                if isFollowing {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.unFollow(userId: userId)))
                } else {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.follow(userId: userId)))
                }
            }
            .bind { result in
                switch result {
                case .success(_):
                    // currenFollowing.accept(!currenFollowing.value)
                    outputReloadTrigger.accept(())
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        outputReloadTrigger
            .withLatestFrom(input.inputProfileType)
            .flatMapLatest { profileType in
                switch profileType {
                case .me:
                    NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.profileMeRead))
                case .other(let otherUserId):
                    NetworkManager.fetchNetwork(model: ProfileModel.self, router:.profile(.otherUserProfileRead(userId: otherUserId)) )
                }
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let profile):
                    print("@@@@###",profile.profileImage)
                    outputProfile.onNext(profile)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            outputProfile: outputProfile.asDriver(onErrorDriveWith: .never()),
            networkError: networkError,
            followState: isFollowing
        )
        
    }
}


/*
 /// 프로필 재조회
 
 */

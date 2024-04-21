//
//  SubProfileViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa


final class SubProfileViewModel: RxViewModelType {
     
    var disposeBag: DisposeBag = .init()
   
    
    struct Input {
        let beCreator: BehaviorRelay<Creator>
        let currentUserId : String
        let leftButtonTap: ControlEvent<Void>
        let rightButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let networkError : Driver<NetworkError>
        let profileModel : Driver<ProfileModel>
    }
    
    func transform(_ input: Input) -> Output {
        
        let beProfile = PublishSubject<ProfileModel> ()
        let networkError = PublishSubject<NetworkError> ()
        let profileType = BehaviorSubject<ProfileType> (value: .me)
        let currentFollowBool = BehaviorRelay<Bool> (value: false)
        
        input.beCreator
            .map { $0.userID }
            .map { userId in
                if userId == input.currentUserId {
                    profileType.onNext(ProfileType.me)
                    return ProfileType.me
                } else {
                    profileType.onNext(ProfileType.other(otherUserId: userId))
                    return ProfileType.other(otherUserId: userId)
                }
            }
            .flatMapLatest { profileType in
                switch profileType {
                case .me :
                    return NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.profileMeRead))
                case .other(let userId):
                    return NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.otherUserProfileRead(userId: userId)))
                }
            }
            .bind { result in
                switch result {
                case .success(let profileModel):
                    beProfile.onNext(profileModel)
                case .failure(let fail):
                    networkError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        // 현 좋아요 상태를 알아야함
        beProfile
            .bind { profileModel in
                let bool = profileModel.followers.filter { $0.userID == input.currentUserId }
                currentFollowBool.accept(!bool.isEmpty)
            }
            .disposed(by: disposeBag)
        
        
        input.leftButtonTap
            .debug()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .withLatestFrom(profileType)
            .debug()
            .compactMap { type in
                if case .other(let userId) = type {
                    return userId
                } else {
                    return nil
                }
            }
            .debug()
            .flatMapLatest { userId in
                if currentFollowBool.value {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.unFollow(userId: userId)))
                } else {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.follow(userId: userId)))
                }
            }
            .bind { result in
                switch result {
                case .success(let followModel):
                    print("현재 :",followModel.followingStatus)
                    currentFollowBool.accept(followModel.followingStatus)
                case .failure(let error):
                    networkError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
            
        
        return Output(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            profileModel: beProfile.asDriver(onErrorDriveWith: .never())
        )
    }
}

/*
 확인할것
 SVProgressHUD
 */

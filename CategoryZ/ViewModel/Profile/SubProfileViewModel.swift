//
//  SubProfileViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

enum FollowORProfile {
    case follow
    case folling
    case modiFyProfile
}

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
        let currnetFollowState : Driver<FollowORProfile>
    }
    
    func transform(_ input: Input) -> Output {
        
        let beProfile = PublishSubject<ProfileModel> ()
        let networkError = PublishSubject<NetworkError> ()
        let profileType = BehaviorSubject<ProfileType> (value: .me)
        let leftButtonState = BehaviorRelay<FollowORProfile> (value: .follow)
        
        input.beCreator
            .map { $0.userID }
            .map { userId in
                if userId == input.currentUserId {
                    profileType.onNext(ProfileType.me)
                    leftButtonState.accept(.modiFyProfile)
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
        
        // 현 팔로잉 상태를 알아야함
        beProfile
            .bind { profileModel in
                if profileModel.userID == input.currentUserId {
                    leftButtonState.accept(.modiFyProfile)
                } else if profileModel.followers.contains(where: { $0.userID == input.currentUserId}) {
                    leftButtonState.accept(.folling)
                } else {
                    leftButtonState.accept(.follow)
                }
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
                
                if leftButtonState.value  == .folling{
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.unFollow(userId: userId)))
                } else {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.follow(userId: userId)))
                }
            }
            .bind { result in
                switch result {
                case .success(let followModel):
                    print("현재 :",followModel.followingStatus)
                    if followModel.followingStatus {
                        leftButtonState.accept(.folling)
                    } else {
                        leftButtonState.accept(.follow)
                    }
                case .failure(let error):
                    networkError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
            
        
        return Output(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            profileModel: beProfile.asDriver(onErrorDriveWith: .never()),
            currnetFollowState: leftButtonState.asDriver()
        )
    }
}

/*
 확인할것
 SVProgressHUD
 */

//
//  FollowerFollowingViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import Foundation
import RxSwift
import RxCocoa

/*
 팔로우 팔로잉 같은 경우 통신은 단 한번만 해야 할것 같다.
 이유 :  1. 만약 바로 반영되면 UX 적으로 생각했을때 실수로 눌렀는데 바로 사라지면
        기분이 좋지 않을것 같다.
 
 뷰가 등장하자마자 본인 프로필인지 아닌지에 따라 보인 프로필 조회 API 를 호출 시켜야
 할것으로 보인다.

 본인인지 아닌지에 따라 버튼이 없어져야 할때도 존재하며
 그 값을 비교해서 뷰에 나타날 글씨들이 바뀌어야 될것이다.
 */


final class FollowerFollowingViewModel: RxViewModelType {
    
    var disposeBag: DisposeBag = .init()
    
    var followUsers: [Creator] = []
    
    
    struct Input {
        let inputPersons: BehaviorRelay<[Creator]>
        let inputFollowTypes: BehaviorRelay<FollowType>
        let startTrigger: ControlEvent<Bool>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let outputOtherUser: Driver<[Creator]>
    }
    
    func transform(_ input: Input) -> Output {
        
        let publishMyProfile = PublishRelay<ProfileModel> ()
        let networkError = PublishSubject<NetworkError> ()
        
        let followTypePersons = PublishSubject<[Creator]>()
        
        // 다른 유저 전용 모델
        let otherUserChangedModel = PublishRelay<Creator> ()
        let publishFollowertype = PublishRelay<ProfileType> ()
        let publishFollowingtype = PublishRelay<ProfileType> ()
            
        // 본인 인지 아닌지에 따라서 보인 프로필 아닐때 본인 프로필 조회 호출
        let isNotMe = input.inputFollowTypes
            .filter { type in
                switch type {
                case .follower(let user):
                    user != .me
                case .following(let user):
                    user != .me
                }
            }
            
        
        // 일단 타인 기준 부터 진행하자.
        // 타인일때 본인 프로필을 불러와 비교가 필요함 본인 프로필 불러오기
        isNotMe
            .take(1)
            .flatMapLatest { type in
                NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.profileMeRead))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    print("본인 프로필 조회 되었는가?")
                    publishMyProfile.accept(model)
                case .failure(let fail):
                    networkError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        // 타인 팔로우/잉 목록 혹은 본인 팔로우/잉 모델 변환
        
        Observable.combineLatest(publishMyProfile, input.inputPersons)
            .map { profileModel, creators in
                let myFollowIds = profileModel
                    .following.map { $0.userID }
                
                return creators.map { creator in
                    print("@@@@",creator.profileImage)

                    creator.isFollow = myFollowIds.contains(creator.userID)
                    return creator
                }
            }
            .bind(with: self) { owner, persons in
                owner.followUsers = persons
                followTypePersons.onNext(owner.followUsers)
            }
            .disposed(by: disposeBag)
        
        return Output(
            networkError: networkError.asDriver(
            onErrorDriveWith: .never()),
            outputOtherUser: followTypePersons.asDriver(onErrorJustReturn: [])
        )
    }
    
    
    
}

/*
 // 팔로워 모드인지 팔로잉 모드인지 구분하기
 input.inputFollowTypes
     .bind { followType in
         switch followType{
         case .follower(let person):
             publishFollowertype.accept(person)
         case .following(let person):
             publishFollowingtype.accept(person)
         }
     }
     .disposed(by: disposeBag)
 
 // 타인일때 팔로워 모드 구성
 Observable
     .combineLatest(publishFollowertype, publishMyProfile)
     .bind(with: self) { owner, combine in

         if case .other(let otherUserId) = combine.0 {
             
         }
     }
 */

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
        let inputProfileType: BehaviorRelay<ProfileType>
        let followType: FollowType
        let inputMyId: String
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let outputOtherUser: Driver<[Creator]>
    }
    
    
    func transform(_ input: Input) -> Output {
        // 현재 뷰컨의 모드
        let followType = input.followType
        // 현재 사용중인 유저의 아이디
        
        // 네트워크 에러 발생시
        let networkError = PublishSubject<NetworkError> ()
        // 현재 뷰컨의 모드의 따른 사람들 결과
        let followTypePersons = BehaviorRelay<[Creator]>(value: [])
        // 다른 유저일때는 사용중인 유저의 프로필이 필요
        let myProfile = PublishRelay<ProfileModel> ()
        // let myProfile = PublishRelay<ProfileModel> ()
        
        
    
        // 다른 유저라면 -> 내 아이디와 비교후 반환 -> 해당 로직은 통합됨
        let inputOtherUser = input.inputProfileType
            
            
        // 다른 유저라면 -> 내 프로필 조회.. ? 해야하네...ㅠㅠㅠ
        inputOtherUser
            .flatMapLatest { _ in
                NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.profileMeRead))
            }
            .bind { result in
                switch result {
                case .success(let model):
                    myProfile.accept(model)
                case .failure(let fail):
                    networkError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        // 다른 유저라면
        // myProfile에서 팔로잉 또는 팔로워 목록을 가져온 후,
        // 해당 목록과 input.inputPersons를 비교하여 isFollow 상태 반영
        // 다른 유저라면 -> 내 프로필 조회 모델 -> 들어온 모델 분석후 방출
        let updatedCreators = Observable.combineLatest(
            myProfile,
            input.inputPersons
        )
            .map { profile, creators -> [Creator] in
                
                let profileIds: Set<String> = {
                    switch followType {
                    case .follower, .following:
                        print(
                            "받은곳에서 팔로워들",
                            profile.followers.map { $0.userID }
                        )
                        return Set(profile.following.map { $0.userID })  // 팔로워의 userID를 가져옴
                    }
                }()
                creators.forEach { creator in
                    print(creator.userID)
                    creator.isFollow = profileIds.contains(creator.userID)
                }
                return creators
            }
        
        updatedCreators
            .bind(with: self) { owner, creators in
                // owner.followUsers.append(contentsOf: creators)
                owner.followUsers = creators
                followTypePersons.accept(owner.followUsers)
            }
            .disposed(by: disposeBag)
        
       
        return Output(
            networkError: networkError.asDriver(
            onErrorDriveWith: .never()),
            outputOtherUser: followTypePersons.asDriver(onErrorJustReturn: [])
        )
    }

}




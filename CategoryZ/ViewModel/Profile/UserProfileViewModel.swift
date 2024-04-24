//
//  UserProfileViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa


struct CustomSectionModel {
    var items: [SNSDataModel]
    
    init(items: [SNSDataModel]) {
        self.items = items
    }
}

final class UserProfileViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private
    var realModel: CustomSectionModel = CustomSectionModel( items: [])
    
    struct Input {
        let inputProfileType: BehaviorRelay<ProfileType>
        let inputProducID: BehaviorRelay<ProductID>
        let inputProfileReloadTrigger: PublishSubject<Void>
        let userId: String
        let leftButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let outputProfile : Driver<ProfileModel>
        let networkError : Driver<NetworkError>
        let postReadMainModel: Driver<[CustomSectionModel]>
        let leftButtonState: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let limit = "10"
        let nextCursor: String? = nil
        var otherId: String? = nil
        
        let currenFollowing = BehaviorRelay<Bool>(value: false)
        
        let networkError = PublishSubject<NetworkError> ()
        let outputProfile = PublishSubject<ProfileModel> ()
        let postReadMainModel = BehaviorRelay<[CustomSectionModel]> (value: [])
        
        let combineRequest = Observable.combineLatest(input.inputProfileType, input.inputProducID)
            
        
        
        /// 프로필 조회 API
        combineRequest.flatMapLatest { profileType, _ in
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
                networkError.onNext(error)
            }
        }
        .disposed(by: disposeBag)
        
        /// 프로필 재조회
        input.inputProfileReloadTrigger
            .withLatestFrom(combineRequest)
            .flatMapLatest { profileType, _ in
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
                    networkError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        combineRequest
            .withUnretained(self)
            .map { owner, request in
                switch request.0 {
                case .me:
                    return ( input.userId,  request.1.identi)
                case .other(let otherUserId):
                    return (otherUserId, request.1.identi)
                }
            }
            .filter { userId, productID in
                userId != nil
            }
            .flatMapLatest { request in
                print("요청시 \(request)")
                return NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.userCasePostRead(userId: request.0!, next: nextCursor, limit: limit, productId: request.1)))
            }
            .bind(with: self) {owner, result in
                switch result {
                case .success(let model):
                    owner.realModel.items = model.data
                    print("통신 결과",model.data)
                    print("통신 결과 : \(model)")
                    postReadMainModel.accept([owner.realModel])
                case .failure(let fail):
                    networkError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        
        let otherCase = input.inputProfileType
            .filter { $0 != .me }

            
        let isFollowing = outputProfile
            .withLatestFrom(input.inputProfileType) { profile, type -> Bool in
                guard case .other = type else { return false }
                return profile.followers.contains { $0.userID == input.userId }
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
                case .success(let model):
                    // currenFollowing.accept(!currenFollowing.value)
                    input.inputProfileReloadTrigger.onNext(())
                case .failure(let error):
                    networkError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    

        return .init(
            outputProfile: outputProfile.asDriver(onErrorDriveWith: .never()),
            networkError: networkError.asDriver(
                onErrorDriveWith: .never()
            ), postReadMainModel: postReadMainModel.asDriver() ,
            leftButtonState: isFollowing
        )
    }
    
}

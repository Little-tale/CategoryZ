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
    var userId: String? = UserIDStorage.shared.userID
    
    private
    var realModel: CustomSectionModel = CustomSectionModel( items: [])
    
    struct Input {
        let inputProfileType: BehaviorRelay<ProfileType>
        let inputProducID: BehaviorRelay<ProductID>
    }
    
    struct Output {
        let outputProfile : Driver<ProfileModel>
        let networkError : Driver<NetworkError>
        let postReadMainModel: Driver<[CustomSectionModel]>
    }
    
    func transform(_ input: Input) -> Output {
        let limit = "10"
        let nextCursor: String? = nil
        
        let networkError = PublishSubject<NetworkError> ()
        let outputProfile = PublishSubject<ProfileModel> ()
        let postReadMainModel = BehaviorRelay<[CustomSectionModel]> (value: [])
        
        let combineRequest = Observable.combineLatest(input.inputProfileType, input.inputProducID)
            
        
        /// 프로필 조회 API
        combineRequest.flatMapLatest { profileType, _ in
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
        
        combineRequest
            .withUnretained(self)
            .map { owner, request in
                switch request.0 {
                case .me:
                    return ( owner.userId,  request.1.identi)
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
        
        return .init(
            outputProfile: outputProfile.asDriver(onErrorDriveWith: .never()),
            networkError: networkError.asDriver(
                onErrorDriveWith: .never()
            ), postReadMainModel: postReadMainModel.asDriver()
        )
    }
    
}

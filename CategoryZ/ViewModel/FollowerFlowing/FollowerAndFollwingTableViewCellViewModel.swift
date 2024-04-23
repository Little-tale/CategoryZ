//
//  FollowerAndFollwingTableViewCellViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FollowerAndFollwingTableViewCellViewModel: RxViewModelType {
    // weak var errorCatch: NetworkErrorCatchProtocol?
    
    var disposeBag: RxSwift.DisposeBag = .init()
        
    struct Input {
        let behaivorModel: BehaviorRelay<Creator>
        let behaivorFollowType: BehaviorRelay<FollowType>
        let buttonTap: ControlEvent<Void>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let changedModel: Driver<Creator>
    }
    
    func transform(_ input: Input) -> Output {
        
        let publishProfileType = PublishRelay<ProfileType> ()
        let networkError = PublishSubject<NetworkError> ()
        let chagedModel = PublishSubject<Creator> ()
        let zipModel = Observable
            .zip(
                publishProfileType,
                input.behaivorModel
            )
        
    
        input.buttonTap
            .withLatestFrom(input.behaivorFollowType)
            .bind { follow in
                switch follow {
                case .follower(let type) , .following(let type):
                    publishProfileType.accept(type)
                }
            }
            .disposed(by: disposeBag)
        
      zipModel
            .flatMapLatest { (profileType, creator) in
                let creator = creator
                creator.isFollow.toggle()
                chagedModel.onNext(creator)
                if creator.isFollow {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.follow(userId: creator.userID)))
                } else {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.unFollow(userId: creator.userID)))
                }
            }
            .withUnretained(self)
            .bind {owner, result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    
                    networkError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
            
            
        
        return Output(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            changedModel: chagedModel.asDriver(onErrorDriveWith: .never())
        )
    }
}

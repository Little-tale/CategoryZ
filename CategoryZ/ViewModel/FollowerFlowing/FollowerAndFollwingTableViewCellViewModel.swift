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
    
    var disposeBag: RxSwift.DisposeBag = .init()
        
    struct Input {
        let behaivorModel: BehaviorRelay<Creator>
        let buttonTap: ControlEvent<Void>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let changedModel: Driver<Creator>
    }
    
    func transform(_ input: Input) -> Output {
        
        let networkError = PublishSubject<NetworkError> ()
        let changedModel = PublishRelay<Creator> ()
        
       input.buttonTap
            .debounce(
                .milliseconds(500),
                      scheduler: MainScheduler.instance
            )
            .withLatestFrom(input.behaivorModel)
            .map { model in
                print("buttonTap Be",model.isFollow)
                model.isFollow.toggle()
                print("buttonTap after1",model.isFollow)
                changedModel.accept(model)
                return model
            }
            .flatMapLatest { creator in
                print("buttonTap after2",creator.isFollow)
                if creator.isFollow {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.follow(userId: creator.userID)))
                } else {
                    return NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.unFollow(userId: creator.userID)))
                }
            }
            .bind { result in
                switch result {
                case .success:
                    break
                case .failure(let fail):
                    networkError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
            
         
            
        
        return Output(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            changedModel: changedModel.asDriver(onErrorDriveWith: .never())
        )
    }
}

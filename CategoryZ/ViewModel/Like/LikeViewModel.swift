//
//  LikeViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private
    var next: String? = nil
    
    private
    let limit = "10"
    
    
    let realModel = BehaviorRelay<[SNSDataModel]> (value: [])
    
    struct Input {
        let startTriggerSub: PublishRelay<Void>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let successData: BehaviorRelay<[SNSDataModel]>
    }
    
    func transform(_ input: Input) -> Output {
        
        let networkError = PublishRelay<NetworkError> ()
        
        input.startTriggerSub
            .withUnretained(self)
            .filter({ owner, void in
                owner.limit != "0"
            })
            .flatMapLatest {owner , _ in
                NetworkManager.fetchNetwork(
                    model: SNSMainModel.self,
                    router: .like(.findLikedPost(
                        next: owner.next,
                        limit: owner.limit
                    ))
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    owner.next = model.nextCursor
                    var before = owner.realModel.value
                    before.append(contentsOf: model.data)
                    owner.realModel.accept(before)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            successData: realModel
        )
    }
    
}

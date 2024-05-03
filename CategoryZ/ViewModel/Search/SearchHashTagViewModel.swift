//
//  SearchHashTagVIewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchHashTagViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    let behaiviorProductID = BehaviorRelay<ProductID> (value: .dailyRoutine)
    
    struct Input {
        let behaiviorText: BehaviorRelay<String>

    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let successModel: Driver<[SNSDataModel]>
    }
    
    func transform(_ input: Input) -> Output {
        var next: String? = nil
        
        let outputModels = BehaviorRelay<[SNSDataModel]> (value: [])
        
        let outputError = PublishRelay<NetworkError> ()
        
        let combineDebounce = Observable.combineLatest(
            input.behaiviorText
                .debounce(.seconds(1) , scheduler: MainScheduler.instance)
                .distinctUntilChanged(),
            behaiviorProductID.distinctUntilChanged()
        )
        
        combineDebounce
            .map({ models in
                next = nil
                return models
            })
            .withUnretained(self)
            .flatMapLatest { owner, ifTag in
                
                return NetworkManager.fetchNetwork(model: SNSMainModel.self, router: .poster(.findHashTag(next: next, limit: "30", productId: ifTag.1.identi, hashTag: ifTag.0 )))
            }
            .bind { result in
                switch result {
                case .success(let model):
                    next = model.nextCursor
                    outputModels.accept(model.data)
                case .failure(let error):
                    outputError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            networkError: outputError.asDriver(onErrorJustReturn: .loginError(statusCode: 419, description: "재시도")),
            successModel: outputModels.asDriver()
        )
    }
    
}

extension SearchHashTagViewModel: SelectedProductId {
    func selected(productID: ProductID) {
        behaiviorProductID.accept(productID)
    }
}

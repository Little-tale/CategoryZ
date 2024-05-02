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
    
    struct Input {
        let behaiviorText: BehaviorRelay<String>
        let behaiviorProductID: BehaviorRelay<ProductID>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let successModel: Driver<[SNSDataModel]>
    }
    
    func transform(_ input: Input) -> Output {
        var next: String? = nil
        
        let outputModels = BehaviorRelay<[SNSDataModel]> (value: [])
        
        let outputError = PublishRelay<NetworkError> ()
        
        input.behaiviorText
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .map({ text in
                next = nil
                return text
            })
            .flatMapLatest { ifTag in
                print(ifTag)
                return NetworkManager.fetchNetwork(model: SNSMainModel.self, router: .poster(.findHashTag(next: next, limit: "30", productId: input.behaiviorProductID.value.identi, hashTag: ifTag)))
            }
            .bind { result in
                switch result {
                case .success(let model):
                    print("엥?",model.data)
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

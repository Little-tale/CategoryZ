//
//  DonateListViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DonateListViewModel: RxViewModelType {
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let startTrigger: Observable<Void>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let successModels: BehaviorRelay<[PaymentData]>
        let emptySignal: Driver<Bool>
    }

    func transform(_ input: Input) -> Output {
        
        let networkError = PublishRelay<NetworkError> ()
        let successModels = BehaviorRelay<[PaymentData]> (value: [])
        
        let publishSignal = BehaviorRelay<Bool> (value: false)
            
        
        input.startTrigger
            .flatMapLatest({ _ in
                NetworkManager.fetchNetwork(
                    model: PaymentsListModel.self,
                    router: .payments(.paymentsList)
                )
            })
            .bind(with: self) { owner, result in
                switch result{
                case .success(let model):
                    publishSignal.accept(model.dataList.isEmpty)
                    successModels.accept(model.dataList)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
    
        
        return Output(
            networkError: networkError.asDriver(onErrorJustReturn: .loginError(statusCode: 419, description: "치명적 에러 발생")),
            successModels: successModels,
            emptySignal: publishSignal.asDriver()
            
        )
    }
    
}

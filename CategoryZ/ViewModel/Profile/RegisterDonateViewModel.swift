//
//  RegisterDonateViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class RegisterDonateViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    
    struct Input {
        let viewWillTrigger: Observable<Void>
        let behaiviorModel: BehaviorRelay<ProfileModel>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let currentIndex: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        
        let behaiviorCurrent = BehaviorRelay(value: true)
        
        let networkError = PublishRelay<NetworkError> ()
        
        let checkModel = PublishRelay<PostReadMainModel> ()
        
    
        input.viewWillTrigger
            .throttle(.milliseconds(50), scheduler: MainScheduler.asyncInstance)
            .flatMapLatest { _ in
                NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.userCasePostRead(
                    userId: input.behaiviorModel.value.userID,
                    next: nil,
                    limit: "5", // 개수는 1개로만 해야함
                    productId: ProductID.userProduct
                )))
            }
            .bind { result in
                switch result {
                case .success(let model):
                    checkModel.accept(model)
                    
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        checkModel.bind { model in
            behaiviorCurrent.accept(model.data.count >= 1)
        }
        .disposed(by: disposeBag)
        
        return Output(
            networkError: networkError.asDriver(onErrorJustReturn: .loginError(statusCode: 419, description: "")),
            currentIndex: behaiviorCurrent.asDriver()
        )
    }
}

/*
 let postsQuery = MainPostQuery(
     title: "",
     content: "#후원",
     content2: "",
     content3: "",
     product_id: ProductID.userProduct)
 
return NetworkManager.fetchNetwork(model: PostModel.self, router: .poster(.postWrite(query: postsQuery)))
 */

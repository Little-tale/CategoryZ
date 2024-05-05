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
        let selectedSegmentIndexAt: PublishRelay<Int>
        let inputProfileModel: ProfileModel
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let currentIndex: Driver<Bool>
        let successTrigger: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        
        let behaiviorCurrent = BehaviorRelay(value: true)
        
        let networkError = PublishRelay<NetworkError> ()
        
        let checkModel = PublishRelay<SNSMainModel> ()
        
        let successTrigger = PublishRelay<Void> ()
        
        var postId = ""
        
        input.viewWillTrigger
            .throttle(.milliseconds(50), scheduler: MainScheduler.asyncInstance)
            .flatMapLatest { _ in
                NetworkManager.fetchNetwork(model: SNSMainModel.self, router: .poster(.userCasePostRead(
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
                    if let post = model.data.first {
                        postId = post.postId
                    }
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        checkModel.bind { model in
            behaiviorCurrent.accept(model.data.count >= 1)
           
        }
        .disposed(by: disposeBag)
        
        // 후원 On을 눌러 설명을 듣고 확인을 눌렀을때
        input.selectedSegmentIndexAt
            .filter { $0 == 0 }
            .flatMapLatest { _ in
                let postsQuery = MainPostQuery(
                    title: "\(input.inputProfileModel.nick)후원",
                    content: "#후원",
                    content2: "",
                    content3: "",
                    product_id: ProductID.userProduct)
                
                return NetworkManager.fetchNetwork(
                    model: SNSDataModel.self,
                    router: .poster(.postWrite(
                        query: postsQuery)
                    )
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success:
                    successTrigger.accept(())
                case .failure(let fail):
                    networkError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
        
        // 후원 off를 눌러 설명을 듣고 확인을 눌렀을때
        input.selectedSegmentIndexAt
            .filter { $0 == 1 }
            .flatMapLatest { current in
                NetworkManager.noneModelRequest(router: .poster(.postDelete(postID: postId)))
            }
            .bind { result in
                switch result {
                case .success:
                    successTrigger.accept(())
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            networkError: networkError.asDriver(onErrorJustReturn: .loginError(statusCode: 419, description: "")),
            currentIndex: behaiviorCurrent.asDriver(),
            successTrigger: successTrigger.asDriver(onErrorJustReturn: ())
        )
    }
}


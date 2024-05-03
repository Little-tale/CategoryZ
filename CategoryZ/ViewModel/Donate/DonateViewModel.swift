//
//  DonateViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa
import iamport_ios

final class DonateViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    let currentIsUser = BehaviorRelay(value: false)
    
    struct Input {
        let inputUserId: BehaviorRelay<String>
        
        let ifSelectedPrice: BehaviorRelay<PriceModel>

        let donateButtonTap: ControlEvent<Void>
        
        // 버튼을 누른후 본인 인증이 완료된다면 제거됨.
        let publishModelResponse: PublishRelay<IamportResponse?>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        
        let successModel: Driver<[SNSDataModel]>
        
        let successProfile: Driver<ProfileModel>
        
        let moveToCheckUserTrigger: Driver<Void>
        
        let moveToDonateView: PublishRelay<DonateModel>
        
        let successTrigger: Driver<DonateModel>
    }
    
    func transform(_ input: Input) -> Output {
        
        var userNick = ""
        var emptyMoPost: SNSDataModel?
        var emptyProduct: DonateModel?
        
        let networkError = PublishRelay<NetworkError> ()
        
        let successModel = PublishRelay<[SNSDataModel]> ()
        
        let successProfile = PublishRelay<ProfileModel> ()
        
        let publishDonateModel = PublishRelay<DonateModel> ()
        
        let moveToCheckUserTrigger = PublishRelay<Void> ()
        
        let startPaymentsTest = PublishRelay<PaymentsModel> ()
        
        let reModelSuccess = PublishRelay<DonateModel> ()
        
        input.inputUserId
            .flatMapLatest { userId in
                NetworkManager.fetchNetwork(model: SNSMainModel.self, router: .poster(.userCasePostRead(
                    userId: userId,
                    next: nil,
                    limit: "1",
                    productId: ProductID.userProduct
                ))
                )
            }
            .bind { result in
                switch result {
                case .success(let model):
                    successModel.accept(model.data)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.inputUserId
            .flatMapLatest { userId in
                return NetworkManager.fetchNetwork(model: ProfileModel.self, router:.profile(.otherUserProfileRead(userId: userId)) )
            }
            .bind { result in
                switch result {
                case .success(let model):
                    userNick = model.nick
                    successProfile.accept(model)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        

        input.donateButtonTap
            .withUnretained(self)
            .withLatestFrom(successModel)
            .filter({ $0.count != 0 })
            .map({ models in
                let model = models.first!
                
                emptyMoPost = model
                
                let selctedPrice = input.ifSelectedPrice.value.rawValue
                let donateModel = DonateModel.init(
                    productName: model.title,
                    buyername: userNick,
                    amount: String(selctedPrice)
                )
                
                return donateModel
            })
            .bind(with: self) { owner, model in
                print("이때 결제 뷰 가야함을 뷰컨에 알리고 받아와")
                publishDonateModel.accept(model)
                emptyProduct = model
            }
            .disposed(by: disposeBag)
        
        input.publishModelResponse
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .map { response in
                if response == nil || emptyMoPost == nil || emptyProduct == nil {
                    // 결제전용 에러 구성해야함
                    networkError.accept(.paymentsValidError(statusCode: 800, description: "결제 문제가 발생하였습니다."))
                }
                return response
            }
            .compactMap { $0 }
            .bind(with: self) { owner, response in
                let post = emptyMoPost!
                
                let product = emptyProduct!
    
                guard let imp_uid = response.imp_uid,
                      let booTrigger = response.success else {
                    networkError.accept(.paymentsValidError(statusCode: 800, description: "결제 서비스 서버 문제가 발생했습니다."))
                    return
                }
                print(booTrigger) // true
                let query = PaymentsModel(
                    impUID: imp_uid,
                    postID: post.postId,
                    productName: product.productName,
                    price: Int(product.amount) ?? 0
                )
                
                startPaymentsTest.accept(query)
            }
            .disposed(by: disposeBag)
        
        startPaymentsTest
            .flatMapLatest { model in
                print("결제 완료건 -> ",model)
                return NetworkManager.noneModelRequest(router: .payments(.validation(paymentsQeury: model)))
            }
            .bind { result in
                switch result {
                case .success:
                    reModelSuccess.accept(emptyProduct!)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            networkError: networkError.asDriver(onErrorJustReturn: .loginError(statusCode: 419, description: "Reload")),
            successModel: successModel.asDriver(onErrorDriveWith: .never()),
            successProfile: successProfile.asDriver(onErrorDriveWith: .never()),
            moveToCheckUserTrigger: moveToCheckUserTrigger.asDriver(onErrorDriveWith: .never()),
            moveToDonateView: publishDonateModel,
            successTrigger: reModelSuccess.asDriver(onErrorDriveWith: .never())
        )
    }
    
}
extension DonateViewModel: checkUserModelDelegate {
    
    func checkdUserCurrect(_ bool: Bool) {
        if bool == true {
            currentIsUser.accept(bool)
        }
    }
    
}

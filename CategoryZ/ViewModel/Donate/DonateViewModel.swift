//
//  DonateViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DonateViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    
    struct Input {
        let inputUserId: BehaviorRelay<String>
        
        let ifSelectedPrice: BehaviorRelay<PriceModel>
        
        // 버튼을 누른후 본인 인증이 완료된다면
        
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        
        let successModel: Driver<[SNSDataModel]>
        
        let successProfile: Driver<ProfileModel>
    }
    
    func transform(_ input: Input) -> Output {
        
        let networkError = PublishRelay<NetworkError> ()
        
        let successModel = PublishRelay<[SNSDataModel]> ()
        
        let successProfile = PublishRelay<ProfileModel> ()
        
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
                    successProfile.accept(model)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(
            networkError: networkError.asDriver(onErrorJustReturn: .loginError(statusCode: 419, description: "Reload")),
            successModel: successModel.asDriver(onErrorDriveWith: .never()),
            successProfile: successProfile.asDriver(onErrorDriveWith: .never())
        )
    }
    
}
extension DonateViewModel: checkUserModelDelegate {
    
    func checkdUserCurrect(_ bool: Bool) {
        if bool == true {
            print(bool)
        }
    }
    
}

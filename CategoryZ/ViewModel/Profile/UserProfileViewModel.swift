//
//  UserProfileViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa


//struct CustomSectionModel {
//    var items: [SNSDataModel]
//    
//    init(items: [SNSDataModel]) {
//        self.items = items
//    }
//}

final class UserProfileViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    
    var realModel: [SNSDataModel] = []
    
    struct Input {
        let inputProfileType: BehaviorRelay<ProfileType>
        let inputProducID: BehaviorRelay<ProductID>
        let userId: String?
        let currentCellAt: BehaviorRelay<Int>
    }
    
    struct Output {
        let networkError : Driver<NetworkError>
        let postReadMainModel: Driver<[SNSDataModel]>
    }
    
    func transform(_ input: Input) -> Output {
        let limit = 15
        let nextCursor: String? = nil
        
        var currentTotal = 0
        let needMoreTrigger = PublishRelay<Void> ()
        
        var otherId: String? = nil
        
        let currenFollowing = BehaviorRelay<Bool>(value: false)
        
        let networkError = PublishSubject<NetworkError> ()
        // let outputProfile = PublishSubject<ProfileModel> ()
        let postReadMainModel = BehaviorRelay<[SNSDataModel]> (value: [])
        
        let combineRequest = Observable.combineLatest(input.inputProfileType, input.inputProducID)
        
        combineRequest
            .withUnretained(self)
            .map { owner, request in
                switch request.0 {
                case .me:
                    return ( input.userId,  request.1.identi)
                case .other(let otherUserId):
                    otherId = otherUserId
                    return (otherUserId, request.1.identi)
                }
            }
            .filter { userId, productID in
                if userId == nil {
                    networkError.onNext(.loginError(statusCode: 419, description: "재로그인"))
                    return false
                } else {
                    return true
                }
            }
            .flatMapLatest { request in
                print("요청시 \(request)")
                return NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.userCasePostRead(userId: request.0!, next: nextCursor, limit: String(limit), productId: request.1)))
            }
            .bind(with: self) {owner, result in
                switch result {
                case .success(let model):
                    owner.realModel = model.data
                    currentTotal = owner.realModel.count
                    print("통신 결과",model.data)
                    print("통신 결과 : \(model)")
                    postReadMainModel.accept(owner.realModel)
                case .failure(let fail):
                    networkError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        
        let otherCase = input.inputProfileType
            .filter { $0 != .me }
        
        input.currentCellAt
            .bind { at in
                if (currentTotal - 3) >= at {
                    needMoreTrigger.accept(())
                }
            }
            .disposed(by: disposeBag)
            
        needMoreTrigger
            .filter { _ in
                nextCursor != "0"
            }
            .map({ _ in
                return nextCursor
            })
            .distinctUntilChanged()
            .withLatestFrom(combineRequest)
            .map { request in
                switch request.0 {
                case .me:
                    return ( input.userId,  request.1.identi)
                case .other(let otherUserId):
                    otherId = otherUserId
                    return (otherUserId, request.1.identi)
                }
            }
            .filter { userId, productID in
                if userId == nil {
                    networkError.onNext(.loginError(statusCode: 419, description: "재로그인"))
                    return false
                } else {
                    return true
                }
            }
            .flatMapLatest { request in
                print("요청시 \(request)")
                return NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.userCasePostRead(userId: request.0!, next: nextCursor, limit: String(limit), productId: request.1)))
            }
            .bind(with: self) {owner, result in
                switch result {
                case .success(let model):
                    owner.realModel.append(contentsOf: model.data)
                    currentTotal = owner.realModel.count
                    print("통신 결과",model.data)
                    print("통신 결과 : \(model)")
                    postReadMainModel.accept(owner.realModel)
                case .failure(let fail):
                    networkError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        return .init(
            networkError: networkError.asDriver(
                onErrorDriveWith: .never()
            ), postReadMainModel: postReadMainModel.asDriver()
        )
    }
    
}

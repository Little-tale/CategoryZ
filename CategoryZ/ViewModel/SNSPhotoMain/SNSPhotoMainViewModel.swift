//
//  SNSPhotoMainViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa
/*
 .flatMap { likeModel, postId in
     NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: likeModel, postId: postId)))
 }
 .bind { result in
     switch result {
     case .success(let likeModel):
         <#code#>
     case .failure(let fail):
         network
     }
 }
 .disposed(by: disposeBag)
 */

protocol LikeStateProtocol: AnyObject {
    func changeLikeState(_ model: LikeQueryModel,_ postId: String)
}

final class SNSPhotoMainViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
   
    // 포스트 데이타들
    private
    let postsDatas = BehaviorRelay<[SNSDataModel]> (value: [])
    
    // 네트워크 에러 발생시
    private
    let networkError = PublishRelay<NetworkError> ()
    

    struct Input {
        // 첫 시작 트리거
        let viewDidAppearTrigger : ControlEvent<Bool>
        // 추가 요청 패이지 트리거
        let needLoadPageTrigger : PublishRelay<Void>
        // 카테고리 선택시
        let selectedProductID: BehaviorRelay<ProductID>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let tableViewItems: Driver<[SNSDataModel]>
        let userIDDriver: BehaviorRelay<String>
    }
    
    func transform(_ input: Input) -> Output {
        let limit = "10"
        
        // 다음 커서
        let nextCursor = BehaviorRelay<String?> (value: nil)
        
        let userId = BehaviorRelay<String> (value: UserIDStorage.shared.userID ?? "" )
        
        // 네트워크 요청시 반환 받는 모델 PostReadMainModel 통신은 됨
        input.viewDidAppearTrigger
            .take(1)
            .filter { $0 == true }
            .flatMap { _ in
                NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.postRead(next: nextCursor.value, limit: limit, productId: input.selectedProductID.value.identi)))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let success):
                    print(success)
                    nextCursor.accept(success.nextCursor)
                    owner.postsDatas.accept(success.data)
                case .failure(let failer):
                    owner.networkError.accept(failer)
                }
            }
            .disposed(by: disposeBag)
        
        
        return .init(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            tableViewItems: postsDatas.asDriver(),
            userIDDriver: userId
        )
    }

}

extension SNSPhotoMainViewModel: LikeStateProtocol {
    
    func changeLikeState(_ model: LikeQueryModel, _ postId: String) {
        print(model)
        guard let userId = UserIDStorage.shared.userID else { return }
        print(model.like_status)
        print(model.currentRow)
        NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: model, postId: postId)))
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let likeModel):
                    var updatePost = owner.postsDatas.value
                    var model = likeModel
                    var willChange = owner.postsDatas.value[model.currentRow]

                    if model.like_status {
                        if !willChange.likes.contains(userId) {
                            
                            willChange.likes.append(userId)
                        }
                    } else {
                        if let index = willChange.likes.firstIndex(of: userId) {
                           
                            willChange.likes.remove(at: index)
                        }
                    }
                    
                    updatePost[model.currentRow] = willChange
                    owner.postsDatas.accept(updatePost)
                case .failure(let error):
                    owner.networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
}

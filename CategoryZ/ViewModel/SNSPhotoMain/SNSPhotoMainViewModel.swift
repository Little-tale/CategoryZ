//
//  SNSPhotoMainViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa


protocol LikeStateProtocol: AnyObject {
    func changeLikeState(_ model: LikeQueryModel,_ postId: String)
}

final class SNSPhotoMainViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
   
    private
    var realPostData: [SNSDataModel] = []
    
    // 포스트 데이타들
    private // Value 접근시 무조건 ..... ㅠㅠㅠ
    var postsDatas = BehaviorRelay<[SNSDataModel]> (value: [])
        
    
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
        
        var test = BehaviorSubject(value: LikeQueryModel(like_status: false))
            
        
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
                    owner.realPostData.append(contentsOf: success.data)
                    owner.postsDatas.accept(owner.realPostData)
                    
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
        
        NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: model, postId: postId)))
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let likeModel):
                    let updatedPosts = owner.postsDatas.value
                    var postToUpdate = updatedPosts[model.currentRow]
                    
                    if likeModel.like_status {
                        if !postToUpdate.likes.contains(userId) {
                            postToUpdate.changeLikeModel(userId, likeBool: true)
                        }
                    } else {
                        postToUpdate.changeLikeModel(userId, likeBool: false)
                    }
                    
                    //updatedPosts[model.currentRow] = postToUpdate
                    owner.realPostData[model.currentRow] = postToUpdate
                    
                    //*/ // 새로운 배열로 업데이트

                case .failure(let error):
                    owner.networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
}
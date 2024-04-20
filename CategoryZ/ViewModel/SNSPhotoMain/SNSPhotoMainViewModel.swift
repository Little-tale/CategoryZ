//
//  SNSPhotoMainViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SNSPhotoMainViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private
    let userId = UserIDStorage.shared.userID
   
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
    
        // 특정 시점에서그때 진짜 UI에 반영
    
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
        
        let singleObservable = NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.postRead(next: nextCursor.value, limit: limit, productId: input.selectedProductID.value.identi)))
    
        
        Observable.merge(
            input.viewDidAppearTrigger
                .filter({ $0 == true })
                .map({ _ in () }),
            input.needLoadPageTrigger.asObservable()
        )
        .flatMapLatest { return singleObservable }
        .bind(with: self) { owner, result in
            switch result {
            case .success(let model):
                nextCursor.accept(model.nextCursor)
                owner.realPostData.append(contentsOf: model.data)
                owner.postsDatas.accept(owner.realPostData)
            case .failure(let error):
                owner.networkError.accept(error)
            }
        }
        .disposed(by: disposeBag)

        
        return .init(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            tableViewItems: postsDatas.asDriver(),
            userIDDriver: userId
        )
    }
    
    func cellEvent(at: IndexPath, isLike: Bool){
        if let userId {
            var like = realPostData[at.row].likes.contains(userId)
            // 유저 이름이 있을때가 좋아요한 상태
            // 유저 이름이 포함되어 있지 않다면 쏘쏘
            // 들어온 데이타가 true or false 일때
            var postData = realPostData[at.row]
            let userHasLiked = postData.likes.contains(userId)
            
            if isLike && !userHasLiked {
                // 사용자가 좋아요를 누르려고 -> 현재 좋아요 상태가 아니라면 좋아요 추가
                postData.likes.append(userId)
                realPostData[at.row] = postData
                // 데이터 모델 업데이트 후 이벤트 방출
                postsDatas.accept(realPostData)
            } else if !isLike && userHasLiked {
                // 사용자가 좋아요를 취소하려고 -> 현재 좋아요 상태라면 좋아요 제거
                postData.likes.removeAll { $0 == userId }
                realPostData[at.row] = postData
                // 데이터 모델 업데이트 후 이벤트 방출
                postsDatas.accept(realPostData)
            }
        }
    }

}

//extension SNSPhotoMainViewModel: LikeStateProtocol {
//    
//    func changeLikeState(_ model: LikeQueryModel, _ postId: String) {
//        print(model)
//        guard let userId = UserIDStorage.shared.userID else { return }
//        
//        NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: model, postId: postId)))
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let likeModel):
//                    let updatedPosts = owner.postsDatas.value
//                    var postToUpdate = updatedPosts[model.currentRow]
//                    
//                    if likeModel.like_status {
//                        if !postToUpdate.likes.contains(userId) {
//                            postToUpdate.changeLikeModel(userId, likeBool: true)
//                        }
//                    } else {
//                        postToUpdate.changeLikeModel(userId, likeBool: false)
//                    }
//                    
////                    updatedPosts[model.currentRow] = postToUpdate
//                    owner.realPostData[model.currentRow] = postToUpdate
//                    // owner.postsDatas.accept(owner.realPostData)
//                    //*/ // 새로운 배열로 업데이트
//
//                case .failure(let error):
//                    owner.networkError.accept(error)
//                }
//            }
//            .disposed(by: disposeBag)
//    }
//    
//    
//}
//
//
//
////            .bind(with: self) { owner, result in
////                switch result {
////                case .success(let success):
////                    print(success)
////                    nextCursor.accept(success.nextCursor)
////                    owner.realPostData.append(contentsOf: success.data)
////                    owner.postsDatas.accept(owner.realPostData)
////
////                case .failure(let failer):
////                    owner.networkError.accept(failer)
////                }
////            }
////            .disposed(by: disposeBag)
//           

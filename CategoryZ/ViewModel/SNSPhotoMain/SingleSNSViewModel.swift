//
//  SingleSNSViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SingleSNSViewModel: RxViewModelType {
    var disposeBag: RxSwift.DisposeBag = .init()
    private
    let userId = UserIDStorage.shared.userID

    struct Input {
        let setDataBe: BehaviorRelay<SNSDataModel>
        let likeButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let isuserLike: BehaviorRelay<LikeQueryModel>
        let likeCount: Driver<Int>
        let messageCount: Driver<Int>
        let imageStrings: Driver<[String]>
        let contents: Driver<String>
        let profile: Driver<Creator>
        
        let networkError: PublishRelay<NetworkError>
    }

    func transform(_ input: Input) -> Output {
        let networkError = PublishRelay<NetworkError> ()
        
        let bebaviorModel = input.setDataBe
        
        let isUserLikeModel = BehaviorRelay<LikeQueryModel> (value: .init(like_status: false))
        
        let likeCount = BehaviorRelay<Int> (value: 0)
        
        let messageCount = BehaviorRelay(value: 0)
        
        let imagesString = BehaviorRelay<[String]>(value: [])
        
        let contents = BehaviorRelay(value: "")
        
        let profile = BehaviorRelay<Creator> (value: .init(userID: "", nick: "", profileImage: ""))
        
        bebaviorModel
            .bind(with: self) { owner, model in
                if model.likes.contains(owner.userId ?? "") {
                    let modelLike = LikeQueryModel(like_status: true)
                    isUserLikeModel.accept(modelLike)
                } else {
                    let modelLike = LikeQueryModel(like_status: false)
                    isUserLikeModel.accept(modelLike)
                }
                print("현재 좋아요 갯수",model.likes)
                likeCount.accept(model.likes.count)
                messageCount.accept(model.comments.count)
                imagesString.accept(model.files)
                contents.accept(model.content)
                profile.accept(model.creator)
            }
            .disposed(by: disposeBag)
        
        input
            .likeButtonTap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { _ in
                var model = isUserLikeModel.value
                print("1",model.like_status) //1. t
                model.like_status.toggle()
                print("2",model.like_status) // f
                return model
            }
            .flatMapLatest { model in
                NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: model, postId: bebaviorModel.value.postId)))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let like):
                    print("sad", like.like_status)
                    let value = bebaviorModel.value
                    
                    guard let id = owner.userId else {
                        networkError.accept(.loginError(statusCode: 419, description: ""))
                        return
                    }
                    isUserLikeModel.accept(like) //f
                    
                    value.changeLikeModel(id, likeBool: like.like_status)// f
                    
                    print("반영 안됨>???",value.likes)

                    var count = likeCount.value
                    
                    if like.like_status {
                        count += 1
                    } else {
                        count -= 1
                    }
                
                    likeCount.accept(count)

                case .failure(let fail):
                    networkError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(
            isuserLike: isUserLikeModel,
            likeCount: likeCount.asDriver(),
            messageCount: messageCount.asDriver(),
            imageStrings: imagesString.asDriver(),
            contents: contents.asDriver(),
            profile: profile.asDriver(),
            networkError: networkError
        )
    }
    
}

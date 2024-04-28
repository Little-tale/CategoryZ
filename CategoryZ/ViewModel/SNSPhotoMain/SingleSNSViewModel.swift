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
        let isuserLike: Driver<LikeQueryModel>
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
                    let modelLike = LikeQueryModel(like_status: true)
                    isUserLikeModel.accept(modelLike)
                }
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
                print("1",model.like_status)
                model.like_status.toggle()
                print("2",model.like_status)
                return model
            }
            .flatMapLatest { model in
                NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: model, postId: bebaviorModel.value.postId)))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let like):
                    let value = bebaviorModel.value
                    guard let id = owner.userId else {
                        networkError.accept(.loginError(statusCode: 419, description: ""))
                        return
                    }
                    print("2.5",value.likes)
                    print("3",like.like_status)
                    
                    value.changeLikeModel(id, likeBool: like.like_status)
                    
                    print("4",value.likes)
                    print("4.5",like)
                    isUserLikeModel.accept(like)
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
            isuserLike: isUserLikeModel.asDriver(),
            likeCount: likeCount.asDriver(),
            messageCount: messageCount.asDriver(),
            imageStrings: imagesString.asDriver(),
            contents: contents.asDriver(),
            profile: profile.asDriver(),
            networkError: networkError
        )
    }
    
}

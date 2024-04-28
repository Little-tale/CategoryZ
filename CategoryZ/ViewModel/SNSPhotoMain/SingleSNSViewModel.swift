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
        
    }
    
    struct Output {
        let isuserLike: Driver<LikeQueryModel>
        let likeCount: Driver<Int>
        let messageCount: Driver<Int>
        let imageStrings: Driver<[String]>
        let contents: Driver<String>
        let profile: Driver<Creator>
    }

    func transform(_ input: Input) -> Output {
    
        let isUserLikeModel = BehaviorRelay<LikeQueryModel> (value: .init(like_status: false))
        
        let likeCount = BehaviorRelay<Int> (value: 0)
        
        let messageCount = BehaviorRelay(value: 0)
        
        let imagesString = BehaviorRelay<[String]>(value: [])
        
        let contents = BehaviorRelay(value: "")
        
        let profile = BehaviorRelay<Creator> (value: .init(userID: "", nick: "", profileImage: ""))
        
        input.setDataBe
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
        
        return Output(
            isuserLike: isUserLikeModel.asDriver(),
            likeCount: likeCount.asDriver(),
            messageCount: messageCount.asDriver(),
            imageStrings: imagesString.asDriver(),
            contents: contents.asDriver(),
            profile: profile.asDriver()
        )
    }
    
}

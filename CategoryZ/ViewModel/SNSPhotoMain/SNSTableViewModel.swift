//
//  SNSTableViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/18/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SNSTableViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()

    
    struct Input {
        let snsModel: BehaviorRelay<SNSDataModel>
        let inputUserId: BehaviorRelay<String>
    }
    
    struct Output {
        let imageURLStrings: Driver<[String]>
        let content: Driver<String>
        let isUserLike: Driver<Bool>
        let userProfileImage: Driver<String?>
        let profileName: Driver<String>
        let likeCount: Driver<String>
        let comentsCount: Driver<String>
        let diffDate: Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
        let imageUrl = BehaviorRelay<[String]> (value: [])
        let contents = BehaviorRelay<String> (value: "")
        let profileImage = PublishRelay<String?> ()
        let profileName = BehaviorRelay(value: "")
        let likeCount = BehaviorRelay(value: "0")
        let comentsCount = BehaviorRelay(value: "0")
       
        let diffDate = BehaviorRelay(value: "")
        ///
        let isUserLike = input.snsModel
            .map { $0.likes }
            .map { userIds in
                if userIds.contains(UserIDStorage.shared.userID ?? "") {
                    return true
                } else {
                    return false
                }
            }
            .asDriver(onErrorJustReturn: false)
            
        
        input.snsModel
            .withUnretained(self)
            .bind { owner, model in
                dump(model)
                imageUrl.accept(model.files) // 이미지 링크
                contents.accept(model.content) // 컨텐트
                // 내 아이디 이거랑 비교해서 해결
                
                let creator = model.creator // 만든이 정보
                profileName.accept(creator.nick) // 이름
                profileImage.accept(creator.profileImage) // 이미지
                
                likeCount.accept(String(model.likes.count))
                
                //댓글 개수
                comentsCount.accept(String(model.comments.count))
                
                 // 날짜 나오는데 현재 날짜와 비교해 몇일전인지 몇시간 전인지 해보자
                diffDate.accept(DateManager.shared.differenceDateString(model.createdAt))
            }
            .disposed(by: disposeBag)
        
        return Output(
            imageURLStrings: imageUrl.asDriver(),
            content: contents.asDriver(),
            isUserLike: isUserLike,
            userProfileImage: profileImage.asDriver(
                onErrorJustReturn: nil
            ),
            profileName: profileName.asDriver(),
            likeCount: likeCount.asDriver(),
            comentsCount: comentsCount.asDriver(),
            diffDate: diffDate.asDriver()
        )
    }
}

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
    
    weak var likeStateProtocol: LikeStateProtocol?

    struct Input {
        let snsModel: BehaviorRelay<SNSDataModel>
        let inputUserId: BehaviorRelay<String>
        let likedButtonTab: ControlEvent<Void>
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
        var currentRow: Int = 0
        /// 좋아요 숫자 재반영을 위한
        var currnetLike: Bool = false
        
        let imageUrl = BehaviorRelay<[String]> (value: [])
        let contents = BehaviorRelay<String> (value: "")
        let profileImage = BehaviorRelay<String?> (value: nil)
        let profileName = BehaviorRelay(value: "")
        let likeCount = BehaviorRelay(value: "0")
        let comentsCount = BehaviorRelay(value: "0")
        let diffDate = BehaviorRelay(value: "")
        
        /// 현재 유저 라이크 모델
        let isUserLikeModel = BehaviorRelay<LikeQueryModel> (value: .init(like_status: false))
       
        input.snsModel
            .map { $0.likes }
            .bind { userIds in
                if userIds.contains(UserIDStorage.shared.userID ?? "") {
                    let model = LikeQueryModel(like_status: true)
                    isUserLikeModel.accept(model)
                    currnetLike = model.like_status
                } else {
                    let model = LikeQueryModel(like_status: false)
                    isUserLikeModel.accept(model)
                    currnetLike = model.like_status
                }
            }
            .disposed(by: disposeBag)
            
        let isUserLike = isUserLikeModel
            .map { $0.like_status }
            .asDriver(onErrorJustReturn: false)
            
        let currnetPostId = BehaviorRelay(value: "")
        
        input.snsModel
            .withUnretained(self)
            .bind { owner, model in
                // dump(model)
                print("프로필: \(model.files)")
                imageUrl.accept(model.files) // 이미지 링크
                contents.accept(model.content) // 컨텐트
                // 내 아이디 이거랑 비교해서 해결
                
                let creator = model.creator // 만든이 정보
                profileName.accept(creator.nick) // 이름
                profileImage.accept(creator.profileImage) // 이미지
                
                likeCount.accept(String(model.likes.count))
        
                currnetPostId.accept(model.postId)
                currentRow = model.currentRow
                //댓글 개수
                comentsCount.accept(String(model.comments.count))
                
                 // 날짜 나오는데 현재 날짜와 비교해 몇일전인지 몇시간 전인지 해보자
                diffDate.accept(DateManager.shared.differenceDateString(model.createdAt))
            }
            .disposed(by: disposeBag)
        
        // 유저 아이디 + 좋아요 상태
        let combineOfUserLike = Observable.combineLatest(
            isUserLikeModel,
            currnetPostId
        )
        
        // 좋아요 버튼 클릭시 (좋아요 토글 과 통신 해야함을 전달)
        input.likedButtonTab
            .withLatestFrom(combineOfUserLike)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { combine in
                var likeTogle = combine.0
                likeTogle.like_status.toggle()
                likeTogle.currentRow = currentRow
                return (likeModel: likeTogle, postId: combine.1)
            }
            .bind(with: self, onNext: { owner, model in
                
                owner.likeStateProtocol?.changeLikeState(model.likeModel, model.postId)
                
            })
            .disposed(by: disposeBag)
        
        input.likedButtonTab
            .withLatestFrom(likeCount)
            .filter({ Int($0) != nil })
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { Count in
                var current = Int(Count)!
                if currnetLike {
                    current -= 1
                } else {
                    current += 1
                }
                likeCount.accept(String(current))
                currnetLike = !currnetLike
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
    deinit {
        print("SNS TableView Cell View Model Deinit")
    }
    
}



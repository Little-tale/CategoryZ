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
    
    weak var errorDelegate: NetworkErrorCatchProtocol?

    struct Input {
        let snsModel: BehaviorRelay<SNSDataModel>
        let likeButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let imageURLStrings: Driver<[String]>
        let content: Driver<String>
        let isUserLike: Driver<Bool>
        let userProfileImage: Driver<String?>
        let profileName: Driver<String>
        let likeCount: BehaviorRelay<Int>
        let comentsCount: Driver<String>
        let diffDate: Driver<String>
        
        let changingModel: PublishSubject<LikeQueryModel>
    }
    
    func transform(_ input: Input) -> Output {
        // var currentRow: Int = 0
        /// 좋아요 숫자 재반영을 위한
        
        
        let imageUrl = BehaviorRelay<[String]> (value: [])
        let contents = BehaviorRelay<String> (value: "")
        let profileImage = PublishRelay<String?> ()
        let profileName = BehaviorRelay(value: "")
        let likeCount = BehaviorRelay(value: 0)
        let comentsCount = BehaviorRelay(value: "0")
        let diffDate = BehaviorRelay(value: "")
        let currentIfLike = BehaviorRelay(value: false)
            
        let changingModel = PublishSubject<LikeQueryModel> ()
        var currnetPostId = ""
        var currnetLike: Bool = false
        
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
                
                likeCount.accept(model.likes.count)
        
                currnetPostId = model.postId
                // currentRow = model.currentRow
                //댓글 개수
                comentsCount.accept(String(model.comments.count))
                
                 // 날짜 나오는데 현재 날짜와 비교해 몇일전인지 몇시간 전인지 해보자
                diffDate.accept(DateManager.shared.differenceDateString(model.createdAt))
                
                // 현재 좋아요배열중 유저 id가 존재하면 반영
                if let userID = UserIDStorage.shared.userID {
                    if model.likes.contains(userID) {
                        currentIfLike.accept(true)
                        currnetLike = true
                    } else {
                        currentIfLike.accept(false)
                        currnetLike = false
                    }
                }
            }
            .disposed(by: disposeBag)
        
//        // 유저 아이디 + 좋아요 상태
//        let combineOfUserLike = Observable.combineLatest(
//            isUserLikeModel,
//            currnetPostId
//        )
        
        // 좋아요 버튼 클릭시 (좋아요 토글 과 통신 해야함을 전달)
        input.likeButtonTap
            .map({ _ in
                var current = !currnetLike
                currnetLike = current
                return LikeQueryModel(like_status: current)
            })
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { like in
                return (likeModel: like, postId: currnetPostId)
            }
            .flatMapLatest { model, postId in
                NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: model, postId: postId)))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let success):
                    changingModel.onNext(success)
                case .failure(let fail):
                    owner.errorDelegate?.errorCatch(fail)
                }
            }
            .disposed(by: disposeBag)
                
        return Output(
            imageURLStrings: imageUrl.asDriver(),
            content: contents.asDriver(),
            isUserLike: currentIfLike.asDriver(),
            userProfileImage: profileImage.asDriver(
                onErrorJustReturn: nil
            ),
            profileName: profileName.asDriver(),
            likeCount: likeCount,
            comentsCount: comentsCount.asDriver(),
            diffDate: diffDate.asDriver(),
            changingModel: changingModel
        )
    }
    
    
}


//            .map { combine in
//                var likeTogle = combine.0
//                likeTogle.like_status.toggle()
//                likeTogle.currentRow = currentRow
//                return (likeModel: likeTogle, postId: combine.1)
//            }
//            .bind(with: self, onNext: { owner, model in
//
//                owner.likeStateProtocol?.changeLikeState(model.likeModel, model.postId)
//
//            })
//            .disposed(by: disposeBag)
        
//        input.likedButtonTab
//            .withLatestFrom(likeCount)
//            .filter({ Int($0) != nil })
//            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
//            .bind { Count in
//                var current = Int(Count)!
//                if currnetLike {
//                    current -= 1
//                } else {
//                    current += 1
//                }
//                likeCount.accept(String(current))
//                currnetLike = !currnetLike
//            }
//            .disposed(by: disposeBag)

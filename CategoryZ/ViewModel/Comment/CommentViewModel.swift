//
//  CommentViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/25/24.
//

import Foundation
import RxSwift
import RxCocoa

/*
 댓글 다는거 부터 테스트를 진행합시다.
 글자수 제한에 다음줄 금지 줘야 하구요
 아무것도 입력하지 않았을때 false
 */

final class CommentViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    let textValid = TextValid()
    
    struct Input {
        let textViewText: ControlProperty<String?>
        let regButtonTap: ControlEvent<Void>
        let postIdInput: BehaviorRelay<String>
        let inputModels: BehaviorRelay<SNSDataModel>
        let deleteIndex: PublishRelay<IndexPath>
        let deleteTrigger: PublishRelay<Void>
    }
    
    struct Output {
        let validText: Driver<String?>
        let regButtonEnabled: Driver<Bool>
        let networkError: Driver<NetworkError>
        let outputModels: BehaviorRelay<SNSDataModel>
    }
    
    func transform(_ input: Input) -> Output {
        // 공통구역
        let networkError = PublishRelay<NetworkError> ()
        
        // 테스트 검사 결과값
            // 텍스트
        let commentValidText = BehaviorRelay<String?>(value: nil)
            // 버튼상태
        let regButtonEnabled = BehaviorRelay(value: false)
        
        textViewLogic(
            textViewText: input.textViewText,
            validText: commentValidText,
            regButtonEnabled: regButtonEnabled
        )
        
        // 포스트 아이디를 통해 버튼을 탭하면 댓글
        let postIdInput = input.postIdInput
        let commentText = commentValidText
        let regButtonTap = input.regButtonTap
        
        let combinePostIdAndComment = Observable
            .combineLatest(postIdInput, commentText)
        
        let models = input.inputModels
            
        
        let originalModelsModel = input.inputModels
            
        // -- 네트워크 에러를 방출할수있음
        // 등록 버튼 클릭시의 로직
        regButtonTapLogic(
            combinePostIdAndComment,
            regButtonTap,
            networkError,
            originalModelsModel
        )
        // 데이터 모델 지우기
        let deleteIndex = input.deleteIndex
        let deleteTrigger = input.deleteTrigger
        
        deleModelLogic(
            deleteIndex,
            deleteTrigger,
            originalModelsModel,
            networkError
        )
        
        
        return Output(
            validText: commentValidText.asDriver(),
            regButtonEnabled: regButtonEnabled.asDriver(),
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            outputModels: models
        )
    }
    
    private
    func deleModelLogic(_
                        deleteIndex: PublishRelay<IndexPath>,
                        _ deleteTrigger: PublishRelay<Void>,
                        _ originalModelsModel: BehaviorRelay<SNSDataModel>,
                        _ networkError: PublishRelay<NetworkError>
    ) {
        let modelCombineCombind = Observable
            .combineLatest(
                deleteIndex,
                originalModelsModel
            )
        
        let publishRealDelete = PublishRelay<CommentsModel> ()
        
        deleteTrigger
            .withLatestFrom(modelCombineCombind)
            .throttle(
                .milliseconds(100),
                scheduler: MainScheduler.instance
            )
            .bind { indexPath, snsDataModel in
                let model = snsDataModel
                print("중간 : ",model.postId)
                let willDeleteModel = model.comments[indexPath.row]
                willDeleteModel.postId = snsDataModel.postId
                publishRealDelete.accept(willDeleteModel)
                model.comments.remove(at: indexPath.row)
                originalModelsModel.accept(model)
            }
            .disposed(by: disposeBag)
        
        publishRealDelete
            .flatMapLatest { model in
    
                return NetworkManager.noneModelRequest(
                    router: .comments(
                        .commentDelete(
                            postId: model.postId,
                            commentsId: model.commentID
                        )
                    )
                )
            }
            .bind { result in
                switch result {
                case .success:
                    NotificationCenter.default.post(name: .changedComment, object: nil, userInfo: [
                        "SNSDataModel" : originalModelsModel.value
                    ])
                case .failure(let fail):
                    networkError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // 텍스트 뷰 로직
    private
    func textViewLogic(
        textViewText: ControlProperty<String?>,
        validText: BehaviorRelay<String?>,
        regButtonEnabled: BehaviorRelay<Bool>
    )  {
        // 테스트 검사 결과값
       textViewText
            .distinctUntilChanged()
            .compactMap{ $0 }
            .bind(with: self) { owner, text in
                let bool = owner.textValid.commentValid(text, maxCount: 300)
                regButtonEnabled.accept(bool)
                if bool {
                    validText.accept(text)
                } else if text == "" {
                    validText.accept(text)
                } else {
                    validText.accept(validText.value)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // 등록 버튼 탭 로직
    private
    func regButtonTapLogic(
        _ combinePostIdAndComment: Observable<(String, String?)>,
        _ regButtonTap: ControlEvent<Void>,
        _ networkError: PublishRelay<NetworkError>,
        _ originalModelsModel: BehaviorRelay<SNSDataModel>
    ) {
        regButtonTap
            .withLatestFrom(combinePostIdAndComment)
            .compactMap { postID, validText -> (String, String)? in
                guard let text = validText else {
                    return nil
                }
                return (postID, text)
            }
            .flatMapLatest { postId, text in
                let commentWriteQuery = CommentWriteQuery(
                    content: text
                )
                return NetworkManager.fetchNetwork(model:CommentsModel.self , router: .comments(.commentsWrite(query: commentWriteQuery, postId: postId)))
            }
            .bind { result in
                switch result {
                case .success(let model):
                    let willChange = originalModelsModel.value
                    
                    //willChange.comments.append(model)
                    willChange.comments.insert(model, at: 0)
                    NotificationCenter.default.post(
                        name: .changedComment,
                        object: nil,
                        userInfo: [
                            "SNSDataModel" : willChange
                        ]
                    )
                    print(model)
                    originalModelsModel.accept(willChange)
                case .failure(let fail):
                    networkError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}

/*
 unowned는 self가 nil이 될 가능성이 존재
 
 weak
 weak는 옵셔널 타입입니다. 그래서 nil이 될 수 있으며 만약 참조하고 있는 인스턴스가 메모리에서 해제될 시, ARC가 nil로 참조값을 대체합니다. 따라서 참조하고 있는 객체가 생명주기가 짧은 경우(weak를 선언한 scope의 객체보다) 사용합니다. (수명이 더 긴 쪽에서 선언)
 unowned
 unowned는 weak와 달리 참조하고 있는 인스턴스가 메모리에서 해제될 시, nil이 되지 않습니다. 만약 참조하고 있는 객체가 매모리에서 해제된 후 접근할 시, crash가 날 수 있습니다. 따라서 참조하고 있는 객체의 생명주기가 현재 scope의 객체보다 생명주기가 더 길거나 같을 경우 사용합니다. (수명이 더 짧은쪽에서 선언)
 */

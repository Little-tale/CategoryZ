//
//  ChattingViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import Foundation
import RxSwift
import RxCocoa
/*
 룸 아이디를 받았으면
 렘에 대해서 조회를 먼저 진행 없다면
 채팅이 정상적으로 이루어졌을때 렘테이블에 생성
 렘 테이블에 반영
 */

final class ChattingViewModel: RxViewModelType {
    
    var disposeBag = DisposeBag()
    
    private
    let repositry = RealmRepository()
    
    private
    let textValid = TextValid()
    
    struct Input {
        let userIDRelay: BehaviorRelay<String>
        let inputText: ControlProperty<String?>
        let sendButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let realmError:Driver<RealmError>
        let saveButtonState: BehaviorRelay<Bool>
        let currentTextViewText: Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
        
        // ERROR
        let realmError = PublishRelay<RealmError> ()
        
        let publishNetError = PublishRelay<NetworkError> ()
        
        // Suceess
        let successChatRoomId = PublishRelay<ChatRoomModel> ()
        
        let chekedRoomModel = PublishRelay<ChatRoomRealmModel> ()
        
        let nilRoomModel = PublishRelay<ChatRoomModel> ()
        
        let saveButtonState = BehaviorRelay(value: false)
        let currentTextViewText = BehaviorRelay(value: "")
        
        input.userIDRelay
            .flatMapLatest { userId in
                let roomQuery = ChatsRoomQuery(opponent_id: userId)
                
                return NetworkManager.fetchNetwork(model: ChatRoomModel.self, router: .Chatting(.createChatRoom(query: roomQuery)))
            }
            .bind { result in
                switch result {
                case .success(let model):
                    print("Success : ",model)
                    successChatRoomId.accept(model)
                case .failure(let error):
                    publishNetError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        // Realm Table 조회
        successChatRoomId
            .bind(with: self) { owner, model in
                
                let result = owner.repositry.findById(type: ChatRoomRealmModel.self, id: model.roomID)
                
                switch result{
                case .success(let roomModel):
                    if let roomModel {
                        chekedRoomModel.accept(roomModel)
                    } else {
                        nilRoomModel.accept(model)
                    }
                case .failure(let error):
                    realmError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        // 분기점 -> 존재할경우 아닐경우
        
        /// 존재 하지 않을경우
        
        
        /// 존재 할 경우
        
    
        
        input.inputText.orEmpty
            .bind(with: self) { owner, string in
                let bool = owner.textValid.commentValid(string, maxCount: 100)
                saveButtonState.accept(bool)
                if bool {
                    currentTextViewText.accept(string)
                } else if string == "" {
                    currentTextViewText.accept(string)
                } else {
                    currentTextViewText.accept(currentTextViewText.value)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            networkError: publishNetError.asDriver(onErrorJustReturn: .unknownError),
            realmError: realmError.asDriver(onErrorDriveWith: .never()),
            saveButtonState: saveButtonState,
            currentTextViewText: currentTextViewText.asDriver()
        )
    }
}

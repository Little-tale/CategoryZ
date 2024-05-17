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
    
    struct Input {
        let userIDRelay: BehaviorRelay<String>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
    }
    
    func transform(_ input: Input) -> Output {
        
        let publishNetError = PublishRelay<NetworkError> ()
        let successChatRoomId = PublishRelay<ChatRoomModel> ()
        
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
        
        
        return Output(
            networkError: publishNetError.asDriver(onErrorJustReturn: .unknownError)
        )
    }
}

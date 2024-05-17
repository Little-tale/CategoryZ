//
//  ChattingViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChattingViewModel: RxViewModelType {
    
    var disposeBag = DisposeBag()
    
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
        
        return Output(
            networkError: publishNetError.asDriver(onErrorJustReturn: .unknownError)
        )
    }
}

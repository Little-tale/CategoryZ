//
//  chattingListViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/20/24.
//

import Foundation
import RxSwift
import RxCocoa

/*
 1. 렘 먼저 뷰에 반영 시켜 놓을것
 2. 렘 채팅 방과 통신과의 결과를 비교 할것.
 
 2.2 lastAt or New 발견시 해당하는 모델 각자 다 조회
 
 3. 만약 통신을 했을때 렘에 없는 모델일 경우 룸 ID,
    생성 날짜, 업데이트 날짜 렘 반영
 
 4. 뷰에 다시한번 반영
 */

struct ChattingListModel {
    var userName: String
    var userProfie: String?
    var lastChat: String
    var updateAt: Date?
    var ifNew: Bool
}

final class ChattingListViewModel: RxViewModelType {
    
    var disposeBag = DisposeBag()
    
    private
    let repository = RealmRepository()
    
    private
    let myId = UserIDStorage.shared.userID
    
    struct Input {
        let viewDidAppear: Observable<Void>
    }
    
    struct Output {
        let chatRoomModels: Driver<[ChattingListModel]>
    }
    
    func transform(_ input: Input) -> Output {
        
        let chatRoomModels = BehaviorRelay<[ChattingListModel]> (value: [])
        
        let successRoomList = PublishRelay<ChatRoomListModel> ()
        
        let realmSearviceError = PublishRelay<RealmServiceManagerError> ()
        
        let networkError = PublishRelay<NetworkError> ()
        
        let dateError = PublishRelay<DateManagerError> ()
        
        let realmError = PublishRelay<RealmError> ()
        
        RealmServiceManager.shared.observeForRoom { result in
            switch result {
            case .success(let success):
                let model = success.map { model in
                    let model =  ChattingListModel(
                        userName: model.otherUserName,
                        userProfie: model.otherUserProfile,
                        lastChat: model.serverLastChat,
                        updateAt: model.lastChatDate,
                        ifNew: model.ifNew
                    )
                    return model
                }
                chatRoomModels.accept(model)
            case .failure(let error):
                realmSearviceError.accept(error)
            }
        }
        
        chatRoomModels
            .skip(1)
            .flatMapLatest({ _ in
                return NetworkManager.fetchNetwork(
                    model: ChatRoomListModel.self,
                    router: .Chatting(.myChatRooms)
                )
            })
            .withUnretained(self)
            .map({ owner, result in
                if owner.myId == nil {
                    networkError.accept(
                        .loginError(
                            statusCode: 419,
                            description: "loginError"
                        )
                    )
                }
                return result
            })
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    successRoomList.accept(model)
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        successRoomList
            .bind(with: self) { owner, model in
                
                model.chatRoomList.forEach { model in
                    
                    let create = DateManager.shared.makeStringToDate(model.createdAt)
                   
                    let other = model.participants.first { $0.userID != owner.myId }
                    
                    guard let other else { return }
                    
                    var contents: String?
                    
                    if !((model.lastChat?.files.isEmpty) != nil) {
                        contents = "[이미지]"
                    } else {
                        contents = model.lastChat?.content
                    }
                    let before = owner.repository.findById(
                        type: ChatRoomRealmModel.self,
                        id: model.roomID
                    )
                    var bool = false
                    var date: Date? = nil
                    switch before {
                    case .success(let success):
                        if let success {
                            let modelDate = DateManager.shared.makeStringToDate(model.updatedAt)
                            
                            guard case .success(let update) = modelDate else {
                                dateError.accept(.failTransform)
                                return
                            }
                            date = update
                            if success.lastChatWatch < update {
                                bool = true
                            }
                        }
                    case .failure(let failure):
                        realmError.accept(failure)
                    }
                    
                    owner.repository.roomUpdate(
                        id: model.roomID,
                        otherUserName: other.nick,
                        otherUserProfile: other.profileImage,
                        lastChatString: contents,
                        ifNew: bool,
                        lastChatDate: date
                    )
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            chatRoomModels: chatRoomModels.asDriver()
        )
    }
}

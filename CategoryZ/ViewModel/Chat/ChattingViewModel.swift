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
    let repository = RealmRepository()
    
    private
    let textValid = TextValid()
    
    private
    let myID = UserIDStorage.shared.userID
    
    // ERROR
    private
    let realmError = PublishRelay<RealmError> ()
    
    private
    let publishNetError = PublishRelay<NetworkError> ()
    
    private
    let dateError = PublishRelay<DateManagerError> ()
    
    private
    let realmServiceError = PublishRelay<RealmServiceManagerError> ()
    
    private // SocketStartTrigger
    let socketStartTrigger = PublishRelay<Void> ()
    
    struct Input {
        let userIDRelay: BehaviorRelay<String>
        let inputText: ControlProperty<String?>
        let sendButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        
        var ifChatRoomModel: ChatRoomModel? = nil
        var ifCharRealmModel: ChatRoomRealmModel? = nil
        
        var firstTrigger: Bool = true
        
        // 채팅방(넷) 모델
        let chatRoomPub = PublishRelay<ChatRoomModel> ()
        
        // 채팅 내역 조회 트리거
        let chatReadTrigger = PublishRelay<ChatRoomModel> ()
        
        // 채팅 내역 결과 트리거
        let chattingResult = PublishRelay<ChatRoomInChatsModel> ()
        
        // 추가적 채팅 내역 렘 모델화(Once) 트리거
        let moreChatOnceTrigger = PublishRelay<[ChatBoxRealmModel]> ()
        
        // 1. RoomID 전환
        input
            .userIDRelay
            .flatMapLatest({ userId in
                
                let query = ChatsRoomQuery(opponent_id: userId)
                return NetworkManager.fetchNetwork(
                    model: ChatRoomModel.self,
                    router: .Chatting(
                        .createChatRoom(query: query)
                    )
                )
            })
            .bind(with: self) { owner, result in
                
                if owner.myID == nil {
                    owner.publishNetError
                        .accept(.loginError(
                            statusCode: 419, description: "ReLogin")
                        )
                }
                
                switch result {
                case .success(let model):
                    chatRoomPub.accept(model)
                    ifChatRoomModel = model
                case .failure(let error):
                    owner.publishNetError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        // 2. 렘 조회 (있을떄 없을때 분기점)
        // 없을때에는 바로 채팅내역 조회
        // 있을때는 최근 날짜를 통해 채팅 내역 조회
        // 단 한번만 이루어질것
        chatRoomPub
            .take(1)
            .withUnretained(self)
            .filter({ _ in
                ifChatRoomModel != nil
            })
            .map({ owner, model in
                owner.repository.findById(
                    type: ChatRoomRealmModel.self,
                    id: model.roomID
                )
            })
            .bind(with: self) {owner, result in
                switch result {
                case .success(let modelOREmpty):
                    if let model = modelOREmpty {
                        ifCharRealmModel = model
                        firstTrigger = false
                    } else {
                        firstTrigger = true
                    }
                    chatReadTrigger.accept(ifChatRoomModel!)
                case .failure(let error):
                    owner.realmError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        // 3. 채팅 내역 조회
        chatReadTrigger
            .withUnretained(self)
            .flatMapLatest({owner, model in
                var date: String? = nil
                
                if let model = ifCharRealmModel {
                    let sorted = owner.repository.chatSorted(model: model.chatBoxs)
                    if let sorted = sorted.first {
                        date = sorted.createAt.description
                    }
                }
                
                return NetworkManager.fetchNetwork(
                    model: ChatRoomInChatsModel.self,
                    router: .Chatting(
                        .readChatingList(
                            cursorDate: date,
                            roomID: model.roomID
                        )
                    )
                )
            })
            .bind(with: self, onNext: { owner, result in
                switch result {
                case .success(let model):
                    chattingResult.accept(model)
                case .failure(let error):
                    owner.publishNetError.accept(error)
                }
            })
            .disposed(by: disposeBag)
        
        // 4. 렘 선 반영 뷰는 렘을 바라볼것 ( 이때 가 분기점,,! )
        // 4.1 만약 추가적 내용이 존재 했더라면, 가져옴( NET )
        chattingResult
            .filter { model in
                return !model.chatList.isEmpty || ifChatRoomModel != nil
            }
            .bind(with: self) { owner, model in
                owner.createChatBoxes(
                    model.chatList,
                    isMe: owner.myID!
                ) { result in
                    switch result {
                    case .success(let models):
                        moreChatOnceTrigger.accept(models)
                    case .failure(let error):
                        owner.dateError.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // 렘모델을 먼저 반영후
        
        
        
        // 5. view반영
      
        return .init()
    }
}

// MARK: Realm Model Creator
extension ChattingViewModel {
    
    func createChatBoxes(
        _ chatModels: [ChatModel],
        isMe: String,
        handler: @escaping( (Result<[ChatBoxRealmModel],DateManagerError>) -> Void)
    ) {
        
        var ifModels: [ChatBoxRealmModel] = []
        
        for model in chatModels {
            let dateResult = DateManager.shared.makeStringToDate(model.createdAt)
            
            switch dateResult {
            case .success(let date):
                let realmModel = ChatBoxRealmModel(
                    id: model.chatID,
                    contentText: model.content,
                    imageFiles: model.files,
                    isMe: isMe == model.sender.userID,
                    createAt: date
                )
                ifModels.append(realmModel)
            case .failure:
                handler(.failure(.failTransform))
                return
            }
        }
        handler(.success(ifModels))
    }
}

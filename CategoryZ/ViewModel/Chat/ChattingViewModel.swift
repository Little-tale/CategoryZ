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
    
    struct Input {
        let userIDRelay: BehaviorRelay<String>
        let inputText: ControlProperty<String?>
        let sendButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let realmError: Driver<RealmError>
        let publishNetError: Driver<NetworkError>
        let dateError: Driver<DateManagerError>
        let realmServiceError: Driver<RealmServiceManagerError>
        let tableViewDraw: Driver<[ChatBoxRealmModel]>
        let socketError: Driver<ChatSocketManagerError>
        let buttonState: Driver<Bool>
        let currentTextState: Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
        
        var ifChatRoomModel: ChatRoomModel? = nil
        var ifChatRoomRealmModel: ChatRoomRealmModel? = nil
        
        let tableViewDraw = BehaviorRelay<[ChatBoxRealmModel]> (value: [])
        
        let socketError = PublishRelay<ChatSocketManagerError> ()
        
        // 채팅방(넷) 모델
        let chatRoomPub = PublishRelay<ChatRoomModel> ()
        
        // 채팅 내역 조회 트리거
        let chatReadTrigger = PublishRelay<ChatRoomModel> ()
        
        // 채팅 내역 결과 트리거
        let chattingResult = PublishRelay<ChatRoomInChatsModel> ()
        
        // 추가적 채팅 내역 렘 모델화(Once) 트리거
        let moreChatOnceTrigger = PublishRelay<[ChatBoxRealmModel]> ()
        
        // 만약 렘에 없어서 새로 생성후 챗추가시
        let nilButmakedRoomTrigger = PublishRelay< (ChatRoomRealmModel, [ChatBoxRealmModel])> ()
        
        // 소켓 연결 트리거
        let socketStartTrigger = PublishRelay<Void> ()
        
        // 렘 데이터 바라볼 트리거
        let startRealmData = PublishRelay<String> ()
        
        
        let buttonState = BehaviorRelay(value: false)
        
        let currentTextState = BehaviorRelay(value: "")
        
        // 0. 0번은 텍스트 변경 감지와 버튼의 상태 관리
        input.inputText.orEmpty
            .bind(with: self) { owner, text in
                let bool = owner.textValid.commentValid(text, maxCount: 200)
                buttonState.accept(bool)
                if bool {
                    currentTextState.accept(text)
                } else if text == "" {
                    currentTextState.accept(text)
                } else {
                    currentTextState.accept(currentTextState.value)
                }
            }
            .disposed(by: disposeBag)
        
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
                    print("RoomID 전환후 모델 \(model)")
                    ifChatRoomModel = model
                    chatRoomPub.accept(model)
                    ChatSocketManager.shared.setID(id: model.roomID)
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
                print("예상외가 아니길 \(ifChatRoomModel != nil)")
                return ifChatRoomModel != nil
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
                    
                    ifChatRoomRealmModel = modelOREmpty
                    
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
                
                // 만약 존재시 이때 바로 뷰는 미리 렘의 데이터를 받아 보고있게
                if let model = ifChatRoomRealmModel {
                    
                    let sorted = owner.repository.chatSorted(model: model.chatBoxs)
                    if let sorted = sorted.first {
                        let datetrans = DateManager.shared.dateToString(date: sorted.createAt)
                        print("날짜가 이상하게 보일가능성 ",datetrans)
                        date = datetrans
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
                if model.chatList.isEmpty {
                    if let ifChatRoomModel {
                        startRealmData.accept(ifChatRoomModel.roomID)
                    }
                }
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
        moreChatOnceTrigger
            .filter({ _ in
                ifChatRoomModel != nil
            })
            .bind(with: self) { owner, models in
                if let chatRoomModel = ifChatRoomRealmModel {
                    
                    let result = owner.repository
                        .addChatBoxesToRealm(models)
            
                    switch result {
                    case .success(let chats):
                        let result = owner.repository
                            .chatRoomInChats(
                                room: chatRoomModel,
                                chats: chats
                            )
                        switch result {
                        case .success(let success):
                            print("반영 성공 : \(success)")
                            startRealmData.accept(success.id)
                            
                        case .failure(let error):
                            owner.realmError.accept(error)
                        }
                    case .failure(let failure):
                        owner.realmError.accept(failure)
                    }
                    
                } else {
                    owner.makeChatRoomRealmModel(
                        model: ifChatRoomModel!) { result in
                            switch result {
                            case .success(let realm):
                                nilButmakedRoomTrigger.accept((realm, models))
                            case .failure(let error):
                                owner.dateError.accept(error)
                            }
                        }
                }
            }
            .disposed(by: disposeBag)
        
        nilButmakedRoomTrigger
            .bind(with: self) { owner, trigger in
                
                let result = owner.repository.add(trigger.0)
                let chats = trigger.1
                
                switch result{
                case .success(let room):
                    
                    let result = owner.repository
                        .addChatBoxesToRealm(chats)
                    
                    switch result {
                    case .success(let chats):
                        let result = owner.repository
                            .chatRoomInChats(
                                room: room,
                                chats: chats
                            )

                        switch result {
                        case .success(let success):
                            print("반영 성공 : \(success)")
                            startRealmData.accept(success.id)
                            ifChatRoomRealmModel = success
                        case .failure(let error):
                            owner.realmError.accept(error)
                        }
                        
                    case .failure(let error):
                        owner.realmError.accept(error)
                    }
                    
                case .failure(let error):
                    owner.realmError.accept(error)
                }
            }
            .disposed(by: disposeBag)
    
        
        // 5 or 3.1. view반영
        startRealmData
            .bind(with: self) {owner, id in
                RealmServiceManager.shared.observeChatBoxes(
                    with: id,
                    ascending: false
                ) { result in
                    switch result {
                    case .success(let success):
                        tableViewDraw.accept(success)
                        socketStartTrigger.accept(())
                    case .failure(let error):
                        owner.realmServiceError.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // 6. 소켓 시작
        socketStartTrigger
            .bind { _ in
                ChatSocketManager.shared.startSocket()
            }
            .disposed(by: disposeBag)
        
        let socketGetData = PublishRelay<ChatModel> ()
        
        // 7. 소켓에서 받은 데이터를 렘에 추가
        ChatSocketManager.shared.chatSocketResult
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    socketGetData.accept(model)
                case .failure(let error):
                    socketError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        // 8. 소켓을 통해 받은 모델을 렘에 반영 (이땐 무조건. 채팅방 렘테이블은 존재)
        socketGetData
            .filter{ _ in
                if ifChatRoomRealmModel != nil {
                    print(" 예상 외 ")
                }
                return ifChatRoomRealmModel != nil
            }
            .bind(with: self) { owner, model in
                
                owner.createChatBoxes(
                    [model],
                    isMe: owner.myID!
                ) { result in
                    switch result {
                    case .success(let success):
                        let result = owner.repository.chatRoomInChats(room: ifChatRoomRealmModel!, chats: success)
                        
                        switch result {
                        case .success(let success):
                            print("좋아요!")
                            break
                        case .failure(let error):
                            owner.realmError.accept(error)
                        }
                    case .failure(let error):
                        owner.dateError.accept(error)
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
        input.sendButtonTap
            .throttle(.milliseconds(90), scheduler: MainScheduler.instance)
            .withLatestFrom(input.inputText.orEmpty)
            .filter({ text  in
                return text != "" && ifChatRoomModel != nil
            })
            .flatMapLatest { string in
                let chatQuery = ChatPostQuery(content: string, files: nil)
                
                return NetworkManager.fetchNetwork(
                    model: ChatModel.self,
                    router: .Chatting(.postChat(
                        qeury: chatQuery, roomID: ifChatRoomModel!.roomID)
                    )
                )
            }
            .filter{ _ in
                if ifChatRoomRealmModel != nil {
                    print(" 예상 외 ")
                }
                return ifChatRoomRealmModel != nil
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    owner.createChatBoxes(
                        [model],
                        isMe: owner.myID!
                    ) { result in
                        switch result {
                        case .success(let success):
                            let result = owner.repository.chatRoomInChats(room: ifChatRoomRealmModel!, chats: success)
                            
                            switch result {
                            case .success(let success):
                                print("좋아요!")
                                break
                            case .failure(let error):
                                owner.realmError.accept(error)
                            }
                        case .failure(let error):
                            owner.dateError.accept(error)
                        }
                    }
                case .failure(let error):
                    owner.publishNetError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            realmError: realmError.asDriver(onErrorDriveWith: .never()),
            publishNetError: publishNetError.asDriver(onErrorDriveWith: .never()),
            dateError: dateError.asDriver(onErrorDriveWith: .never()),
            realmServiceError: realmServiceError.asDriver(onErrorDriveWith: .never()),
            tableViewDraw: tableViewDraw.asDriver(),
            socketError: socketError.asDriver(onErrorDriveWith: .never()),
            buttonState: buttonState.asDriver(),
            currentTextState: currentTextState.asDriver()
        )
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
    
    private
    func makeChatRoomRealmModel(
        model: ChatRoomModel,
        handler: @escaping((Result<ChatRoomRealmModel,DateManagerError>) -> Void)
    ){
        
        let creatDateResult = DateManager.shared.makeStringToDate(model.createdAt)
        
        guard case .success(let creatDate) = creatDateResult else {
            print("date Error : creatDateResult")
            handler(.failure(.failTransform))
            return
        }
        
        let updatedResult = DateManager.shared.makeStringToDate(model.updatedAt)
        
        guard case .success(let updatedAt) = updatedResult else {
            print("date Error : failTransform")
            handler(.failure(.failTransform))
            return
        }
        
        guard let otherUser = model.participants.last else {
            print("사실상 불가능한 에러")
            publishNetError.accept(.loginError(
                statusCode: 419,
                description: "치명적 이슈")
            )
            handler(.failure(.failTransform))
            return
        }
        
        let model = ChatRoomRealmModel(
            roomId: model.roomID,
            createAt: creatDate,
            updateAt: updatedAt,
            otherUserName: otherUser.nick
        )
        
        handler(.success(model))
    }
}

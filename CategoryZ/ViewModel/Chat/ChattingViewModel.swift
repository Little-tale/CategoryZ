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
        let dateError: Driver<DateManagerError>
    }
    
    func transform(_ input: Input) -> Output {
        
        var noneDataTrigger = true
        
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
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    print("Success : ",model)
                    successChatRoomId.accept(model)
                case .failure(let error):
                    owner.publishNetError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        // Realm Table 조회
        successChatRoomId
            .bind(with: self) { owner, model in
                
                let result = owner.repository.findById(type: ChatRoomRealmModel.self, id: model.roomID)
                
                switch result{
                case .success(let roomModel):
                    if let roomModel {
                        chekedRoomModel.accept(roomModel)
                    } else {
                        nilRoomModel.accept(model)
                        noneDataTrigger = false
                    }
                case .failure(let error):
                    owner.realmError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        // 분기점 -> 존재할경우 아닐경우
        
        /// 존재 하지 않을경우
        nilRoomModel
            .filter({ _ in
                noneDataTrigger == true
            })
            .flatMapLatest { model in
                /// 요청 전체 채팅을 달라고.
                return NetworkManager.fetchNetwork(model: ChatRoomInChatsModel.self, router: .Chatting(.readChatingList(roomID: model.roomID)))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    owner.reMakeModel(model)
                case .failure(let fail):
                    owner.publishNetError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
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
            currentTextViewText: currentTextViewText.asDriver(), dateError: dateError.asDriver(onErrorDriveWith: .never())
        )
    }
}


// ChattingModel Is EMPTY?
extension ChattingViewModel {
    
    private
    func reMakeModel(_ model: ChatRoomInChatsModel) {
        
        guard let myID else {
            publishNetError.accept(.loginError(statusCode: 419, description: "Re login"))
            return
        }
        
        if !model.chatList.isEmpty {
            print("비어있지 않은 로직 시작")
            var remake: [ChatBoxModel] = []
            
            model.chatList.forEach { model in
                
               let dateResult = DateManager.shared.makeStringToDate(model.createdAt)
                
                switch dateResult {
                case .success(let date):
                    let reModel = makeModel(model: model, date)
                    remake.append(reModel)
                    
                case .failure(let error):
                    dateError.accept(error)
                }
            }
            let realmResult = repository.addChatBoxesToRealm(remake)
            
            passCaseRealm(caseOF: realmResult)
        } else {
            print("비어있어!")
        }
    }
    
    private
    func makeModel(model:  ChatModel,_ date: Date) -> ChatBoxModel {
        
        let reModel = ChatBoxModel(
            id: model.chatID,
            imageFiles: model.files,
            isMe: myID == model.sender.userID,
            createAt: date
        )
        
        return reModel
    }
    
    private
    func passCaseRealm(caseOF: Result<Void, RealmError>) {
        switch caseOF {
        case .success(let success):
            print("성공입니다.")
            break
        case .failure(let failure):
            realmError.accept(failure)
        }
    }
}

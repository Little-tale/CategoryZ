//
//  RealmRepository.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation
import RealmSwift
import RxSwift

protocol RealmRepositoryType: AnyObject {
    func fetchAll<M: Object>(type modelType: M.Type) -> Result<Results<M>,RealmError>
    
    @discardableResult
    func add<M:Object>(_ model: M) -> Result<M,RealmError>
    
    func remove(_ model: Object) -> Result<Void,RealmError>
    
    func findById<M: Object & RealmFindType>(type modelType: M.Type, id: M.ID) -> Result< M? , RealmError>
}

protocol RealmFindType {
    
    associatedtype ID: Equatable
    var id: ID { get set }
    
}

final class RealmRepository: RealmRepositoryType {
   
    private
    var realm: Realm?
    
    init() {
        do {
            let realms = try Realm()
            realm = realms
            print("렘 주소",realms.configuration.fileURL)
        } catch {
            print("렘 자체 문제 ")
            realm = nil
        }
    }
    
    func fetchAll<M>(type modelType: M.Type) -> Result<RealmSwift.Results<M>, RealmError> where M : Object {
        guard let realm else { return .failure(.cantLoadRealm)}
        
        return .success(realm.objects(modelType))
    }
   
    @discardableResult
    func add<M>(_ model: M) -> Result<M, RealmError> where M : Object {
        guard let realm else { return .failure(.cantLoadRealm)}
        do {
            try realm.write {
                realm.add(model, update: .modified)
            }
            return .success(model)
        } catch {
            return .failure(.failAdd)
        }
    }
    
    func remove(_ model: Object) -> Result<Void, RealmError> {
        guard let realm else { return .failure(.cantLoadRealm)}
        do {
            try realm.write {
                realm.delete(model)
            }
            return .success(())
        } catch {
            return .failure(.failRemove)
        }
    }
    
    func findById<M>(type modelType: M.Type, id: M.ID) -> Result< M? , RealmError> where M: Object & RealmFindType {
        guard let realm else { return .failure(.cantLoadRealm) }
        
        let object = realm.objects(modelType).where { $0.id == id }.first
        
        return .success(object)
    }
    
    func findIDAndRemove<M>(type modelType: M.Type, id: M.ID) -> Result<Void, RealmError> where M: Object & RealmFindType{
        
        let findResult = findById(type: modelType, id: id)
        
        switch findResult {
        case .success(let success):
            
            guard let success else { return .failure(.cantFindModel)}
            
            return remove(success)
        case .failure:
            return .failure(.cantFindModel)
        }
    }
    
    
    
    func addChatBoxesToRealm(_ chatBoxes: [ChatBoxRealmModel]) -> Result<[ChatBoxRealmModel], RealmError> {
        
        guard let realm = realm else {
            return .failure(.cantLoadRealm)
        }
        
        do {
            try realm.write {
                realm.add(chatBoxes, update: .modified)
            }
            return.success(chatBoxes)
        } catch {
            return .failure(.failAdd)
        }
    }
    
    @discardableResult
    func chatRoomInChats(
        room: ChatRoomRealmModel,
        chats: [ChatBoxRealmModel]) -> Result<ChatRoomRealmModel,RealmError>
    {
        guard let realm = realm else {
            return .failure(.cantLoadRealm)
        }
        do {
            try realm.write {
                chats.forEach { chat in
                    room.chatBoxs.append(chat)
                }
                
                let result = room.chatBoxs.sorted(byKeyPath: "createAt", ascending: false)
                if let result =  result.first {
                    
                    if !result.imageFiles.isEmpty {
                        room.serverLastChat = "이미지"
                    } else {
                        if let text = result.contentText{
                            room.serverLastChat = text
                        }
                    }
                }
            }
            return .success(room)
        } catch {
            return .failure(.failAdd)
        }
    }
    
    
    func chatSorted(model chatBoxs: List<ChatBoxRealmModel>) -> [ChatBoxRealmModel]{
        
        let sorted = chatBoxs.sorted(byKeyPath: "createAt", ascending: false)
     
        return Array(sorted)
    }
}


extension RealmRepository {
    
    func addChatRoom(
        _ room: ChatRoomRealmModel
    ) -> Single<Result<ChatRoomRealmModel,RealmError>>
    {
        return Single<Result<ChatRoomRealmModel,RealmError>>.create {[weak self] observer in
            guard let self else {
                observer(.success(.failure(.cantLoadRealm)))
                return Disposables.create()
            }
            guard let realm else {
                observer(.success(.failure(.cantLoadRealm)))
                return Disposables.create()
            }
            do {
                try realm.write {
                    realm.add(room, update: .modified)
                }
                observer(.success(.success(room)))
                
            } catch {
                observer(.success(.failure(.failAdd)))
            }
            return Disposables.create()
        }
    }

    func addChatBoxes(
        _ chats: [ChatBoxRealmModel]
    ) -> Single<Result<[ChatBoxRealmModel], RealmError>>
    {
        return Single.create {[weak self] observer in
            
            guard let self else {
                observer(.success(.failure(.cantLoadRealm)))
                return Disposables.create()
            }
            do {
                guard let realm else {
                    observer(.success(.failure(.cantLoadRealm)))
                    return Disposables.create()
                }
                try realm.write {
                    for chat in chats {
                        realm.add(chat, update: .modified)
                    }
                }
                observer(.success(.success(chats)))
            } catch {
                observer(.success(.failure(.failAdd)))
            }
            
            return Disposables.create()
        }
    }
}

extension RealmRepository {
    
    @discardableResult
    func roomUpdate(
        id: String,
        createAt: Date,
        updateAt: Date,
        otherUserName: String,
        otherUserProfile: String?,
        lastChatWatch: Date
    ) -> ChatRoomRealmModel? {
        guard let realm else { return nil }
        do {
            try realm.write {
                realm.create(ChatRoomRealmModel.self,
                             value: [
                                "id": id,
                                "createAt":createAt,
                                "updateAt": updateAt,
                                "otherUserName": otherUserName,
                                "otherUserProfile": otherUserProfile as Any,
                                "lastChatWatch": lastChatWatch],
                             update: .modified)
            }
            
            return realm.object(ofType: ChatRoomRealmModel.self, forPrimaryKey: id)
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func roomUpdate(roomId: String, lastChatString: String) -> ChatRoomRealmModel? {
        guard let realm else { return nil }
        do {
            try realm.write {
                realm.create(ChatRoomRealmModel.self,
                             value: [
                                "id": roomId,
                                "serverLastChat": lastChatString
                                ],
                             update: .modified)
            }
            
            return realm.object(ofType: ChatRoomRealmModel.self, forPrimaryKey: roomId)
        } catch {
            return nil
        }
    }
    
}

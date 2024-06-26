//
//  RealmServiceManager.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation
import RealmSwift

enum RealmServiceManagerError: Error, ErrorMessage {
    case cantInitRealm
    case cantGetItem
    case ifEmpty
    
    var message: String {
        switch self {
        case .cantInitRealm:
            return "현재 서비스에 문제가 발생했어요 (DB)"
        case .cantGetItem:
            return "아이템을 가져올수가 없어요"
        case .ifEmpty:
            return "데이터 없음. 에러는 아님"
        }
    }
}

final class RealmServiceManager {

    static
    let shared = RealmServiceManager()
    
    private 
    var notification: NotificationToken?
    
    private
    var realm: Realm?
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            realm = nil
        }
    }
    
    func stop() {
        notification?.invalidate()
    }
    
    deinit {
        notification?.invalidate()
    }
}

extension RealmServiceManager {
    
    func observeChatBoxes(
        with roomID: String,
        ascending: Bool,
        onChange: @escaping (Result<[ChatBoxRealmModel], RealmServiceManagerError>) -> Void
    ) {
        stop()
        guard let realm = realm else {
            onChange(.failure(.cantInitRealm))
            return
        }
        guard let chatRoomModel = realm.object(ofType: ChatRoomRealmModel.self, forPrimaryKey: roomID) else {
            print("존재 하지 않음")
            onChange(.failure(.ifEmpty))
            return
        }
        
        let chatBoxResults = chatRoomModel.chatBoxs.sorted(byKeyPath: "createAt", ascending: ascending)
        
        notification = chatBoxResults.observe({ changes in
            switch changes {
            case .initial(let models):
                print("현재 렘 서비스 입장(이닛) \(models)")
                dump(models)
                onChange(.success(Array(models)))
            case .update(let models, _, _, _):
                print("현재 렘 서비스 입장(업데이트) \(models)")
                onChange(.success(Array(models)))
            case .error(_):
                
                onChange(.failure(.cantGetItem))
            }
        })
    }
}

extension RealmServiceManager {
    func observeForRoom(
        onChange: @escaping (
            Result<[ChatRoomRealmModel], RealmServiceManagerError>
        ) -> Void
    ) {
        
        guard let realm = realm else {
            onChange(.failure(.cantInitRealm))
            return
        }
        let models = realm.objects(ChatRoomRealmModel.self)
        
        let sorted = models.sorted(byKeyPath: "updateAt", ascending: false)
        
        notification = sorted.observe{ changed in
            switch changed {
            case .initial(let models):
                print("현재 렘 서비스 입장(이닛) \(models)")
                dump(models)
                onChange(.success(Array(models)))
            case .update(let models, _, _, _):
                print("현재 렘 서비스 입장(업데이트) \(models)")
                onChange(.success(Array(models)))
            case .error(_):
                onChange(.failure(.cantGetItem))
            }
        }
    }
}

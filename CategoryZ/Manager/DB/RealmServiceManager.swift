//
//  RealmServiceManager.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation
import RealmSwift

enum RealmServiceManagerError: Error {
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
    
    func observeChatBoxes(
        with roomID: String,
        ascending: Bool,
        onChange: @escaping (Result<[ChatBoxModel], RealmServiceManagerError>) -> Void
    ) {
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
                
                onChange(.success(Array(models)))
            case .update(let models, _, _, _):
    
                onChange(.success(Array(models)))
            case .error(let error):
                
                onChange(.failure(.cantGetItem))
            }
        })
    }
    
    func stop() {
        notification?.invalidate()
    }
    
    deinit {
        notification?.invalidate()
    }
}

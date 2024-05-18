//
//  RealmRepository.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation
import RealmSwift


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
        guard let realm else { return .failure(.cantLoadRealm) }
        
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
    
    
    
}

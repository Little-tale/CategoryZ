//
//  UserIDStorage.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import Foundation
import KeychainAccess


final class UserIDStorage {
    
    static let shared = UserIDStorage()
    
    private let keyChain = Keychain(service: UserIdStorageKeyChain.service.rawValue)
    
    
    var userID: String? {
        get {
            return try? keyChain.get(UserIdStorageKeyChain.userID.rawValue)
        }
        set {
            
            try? keyChain.set(newValue ?? "", key: UserIdStorageKeyChain.userID.rawValue)
        }
    }
    
    
}

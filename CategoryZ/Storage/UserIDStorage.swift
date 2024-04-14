//
//  UserIDStorage.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import Foundation
import KeychainAccess

extension UserIDStorage {
    
    enum UserIdStorageKeyChain: String {
        case service = "com.CategoryZ.UserIdService"
        case userID
    }
}

final class UserIDStorage {
    
    static let shared = UserIDStorage()
    
    private let keyChain = Keychain(service: UserIdStorageKeyChain.service.rawValue)
    
    
    var userID: String? {
        get {
            return try? keyChain.get(UserIdStorageKeyChain.userID.rawValue)
        }
        set {
            print("유저 아이디 : \(newValue ?? "")")
            try? keyChain.set(newValue ?? "", key: UserIdStorageKeyChain.userID.rawValue)
        }
    }
    
    
}

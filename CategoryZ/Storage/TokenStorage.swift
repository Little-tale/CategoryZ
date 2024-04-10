//
//  TokenStorage.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation
import KeychainAccess


extension TokenStorage {
    
    enum TokenStorageKeychain: String {
        case searvice = "com.CategoryZ.tokenservice"
        case accessToken
        case refreshToken
    }
    
}


final class TokenStorage {
    
    static let shared = TokenStorage()
    
    private let keyChain = Keychain(service: TokenStorageKeychain.searvice.rawValue)
    
    var accessToken: String? {
        get {
            return try? keyChain.get(TokenStorageKeychain.accessToken.rawValue)
        }
        set {
            try? keyChain.set(newValue ?? "", key: TokenStorageKeychain.accessToken.rawValue)
        }
    }
    
    var refreshToken: String? {
        get {
            return try? keyChain.get(TokenStorageKeychain.refreshToken.rawValue)
        }
        set {
            try? keyChain.set(newValue ?? "", key: TokenStorageKeychain.refreshToken.rawValue)
        }
    }
    
    
}

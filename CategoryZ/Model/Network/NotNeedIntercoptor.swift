//
//  NotNeedIntercoptor.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation


enum NotNeedInterceptor: String, CaseIterable {
    case login = "/users/login"
    case join = "/users/join"
    case email = "/validation/email"
    
    var path: String {
        return self.rawValue
    }
}

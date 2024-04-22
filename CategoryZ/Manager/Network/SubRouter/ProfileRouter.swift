//
//  ProfileRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import Foundation
import Alamofire

enum ProfileRouter {
    case profileMeRead
    case profileMeModify
    case otherUserProfileRead(userId: String)
}

extension ProfileRouter: TargetType {
 
    var method: Alamofire.HTTPMethod {
        switch self {
        case .profileMeRead, .otherUserProfileRead:
            return .get
        case .profileMeModify:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .profileMeRead:
            return PathRouter.usersMe.path + "/profile"
        case .profileMeModify:
            return PathRouter.usersMe.path + "/profile"
        case .otherUserProfileRead(let userId):
            return PathRouter.users.path + "/\(userId)" + "/profile"
        }
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .profileMeRead, .profileMeModify, .otherUserProfileRead:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .profileMeRead, .otherUserProfileRead:
            return [
                NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue
            ]
        case .profileMeModify:
            return [
                NetHTTPHeader.sesacKey.rawValue:
                    APIKey.sesacKey.rawValue,
                NetHTTPHeader.contentType.rawValue:
                    NetHTTPHeader.multipart.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .profileMeRead, .profileMeModify, .otherUserProfileRead:
            return nil
        }
    }
    
    var version: String {
        switch self {
        case .profileMeRead, .profileMeModify, .otherUserProfileRead:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .profileMeRead, .profileMeModify, .otherUserProfileRead:
            return nil
        }
    }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .profileMeRead, .otherUserProfileRead:
            return .usurWithDrawError(statusCode: errorCode, description: description)
        case .profileMeModify:
            return .profileModifyError(statusCode: errorCode, description: description)
        }
    }
    
    
}

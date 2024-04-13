//
//  NetworkRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation
import Alamofire

enum authenticationRouter {
    case login(query: LoginQuery)
    case join(query: JoinQuery)
    case emailVaild(query: EmailValidationQuery)
    case refreshTokken(access: String, Refresh: String)
    case userWithDraw
}


extension authenticationRouter: TargetType {
    
    var baseUrl: URL? {
        return URL( string: APIKey.baseURL.rawValue )
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .join, .emailVaild:
            return .post
            
        case .refreshTokken, .userWithDraw:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return PathRouter.users.path + "/login"
        case .join:
            return PathRouter.users.path + "/join"
        case .emailVaild:
            return PathRouter.validation.path + "/email"
        case .refreshTokken:
            return PathRouter.auth.path + "/refresh"
        case .userWithDraw:
            return PathRouter.users.path + "/withdraw"
        }
    }
    
    var version: String {
        switch self {
        case .login,.join, .emailVaild, .refreshTokken,.userWithDraw:
            return "v1/"
        }
    }
    
    var parametters: Parameters? { // get
        switch self {
        case .login, .join, .emailVaild,
                .refreshTokken, .userWithDraw:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .login, .join, .emailVaild:
            return [
                NetHTTPHeader.contentType.rawValue :
                    NetHTTPHeader.json.rawValue,
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue
            ]
        case .refreshTokken(let access, let refresh):
            return [
                NetHTTPHeader.authorization.rawValue :
                    access,
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue,
                NetHTTPHeader.refresh.rawValue :
                    refresh
            ]
        case .userWithDraw: // 60PFsVaFr9iSRk
            print("시점: ", TokenStorage.shared.accessToken ?? "토큰 없쪄")
            return [
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? { // Post ->
        switch self {
        case .login(let query):
            return jsEncoding(query)
        case .join(let query):
            return jsEncoding(query)
        case .emailVaild(let query):
            return jsEncoding(query)
        case .refreshTokken, .userWithDraw:
            return nil
        }
    }
    
    /// 각 API 에러 담당
    func errorCase(_ errorCode: Int,_ description: String) -> NetworkError {
        switch self {
        case .login:
            return .loginError(statusCode: errorCode, description: description)
            
        case .join:
            return .joinError(statusCode: errorCode, description: description)
            
        case .emailVaild:
            return .emailValidError(statusCode: errorCode, description: description)
            
        case .refreshTokken:
            return .refreshTokkenError(statusCode: errorCode, description: description)
            
        case .userWithDraw:
            return .usurWithDrawError(statusCode: errorCode, description: description)
        }
    }
    
    
    
}


extension authenticationRouter {
    
    fileprivate func jsEncoding(_ target: Encodable) -> Data? {

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let result = try  encoder.encode(target)
            print(result)
            return result
        } catch {
            return nil
        }

    }
}




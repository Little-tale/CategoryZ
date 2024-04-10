//
//  NetworkRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation
import Alamofire

enum NetworkRouter {
    case login(query: LoginQuery)
    case join(query: JoinQuery)
}

extension NetworkRouter: TargetType {
    
    var baseUrl: URL? {
        return URL( string: APIKey.testURL.rawValue )
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .join:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/users/login"
        case .join:
            return "/users/join"
        }
    }
    
    var parametters: Parameters? {
        switch self {
        case .login:
            return nil
        case .join:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .login, .join:
            return [
                NetHTTPHeader.contentType.rawValue :
                    NetHTTPHeader.json.rawValue,
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue
            ]
       
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case .login(let query):
            return jsEncoding(query)
        case .join(let query):
            return jsEncoding(query)
        }
    }
    
    func errorCase(_ errorCode: Int) -> NetworkError {
        switch self {
        case .login:
            return .loginError(statusCode: errorCode, description: "loginError")
        case .join:
            return .joinError(statusCode: errorCode, description: "회원가입 문제 확실")
        }
    }
    
    func commonTest(status: Int) -> NetworkError? {
        switch status {
        case 420, 429, 444, 500:
            return .commonError(status: status)
        default:
            return nil
        }
    }
    
}


extension NetworkRouter {
    fileprivate func jsEncoding(_ target: Encodable) -> Data? {
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            return try encoder.encode(target)
        } catch {
            return nil
        }
    }
}

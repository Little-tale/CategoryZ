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
    case emailVaild(query: EmailValidationQuery)
    
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
        case .emailVaild:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/users/login"
        case .join:
            return "/users/join"
        case .emailVaild:
            return "/validation/email"
        }
    }
    
    var parametters: Parameters? {
        switch self {
        case .login, .join, .emailVaild:
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
        case .emailVaild(let query):
            return jsEncoding(query)
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
        }
    }
    
    /// 공통 에러 부분 담당
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

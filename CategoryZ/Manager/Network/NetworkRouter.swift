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
    
}



extension NetworkRouter: TargetType {
    
    var baseUrl: URL? {
        return URL( string: APIKey.testURL.rawValue )
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/users/login"
        }
    }
    
    var parametters: Parameters? {
        switch self {
        case .login:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .login :
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
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            do {
                return try encoder.encode(query)
            } catch {
                return nil
            }
        }
        
    }
    
    
}

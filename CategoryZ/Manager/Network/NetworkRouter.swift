//
//  NetworkRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/12/24.
//

import Foundation
import Alamofire


protocol ErrorCase {
    func errorCase(_ errorCode: Int,_ description: String) -> NetworkError
}

enum NetworkRouter {
    case authentication(authenticationRouter)
    case poster(PostsRouter)
    case comments(CommentRouter)
}

extension NetworkRouter: URLRequestConvertible {
    
    func asURLRequest() throws -> URLRequest {
        do {
            switch self {
                
            case .authentication(let router):
                return try router.asURLRequest()
                
            case .poster(let router):
                return try router.asURLRequest()
                
            case .comments(let router):
                return try router.asURLRequest()
            }
        } catch {
            throw URLError(.badURL)
        }
    }
}

extension NetworkRouter: ErrorCase {
    func errorCase(_ errorCode: Int,_ description: String) -> NetworkError {
        switch self {
        case .authentication(let authenticationRouter):
            return authenticationRouter.errorCase(errorCode, description)
            
        case .poster(let postsRouter):
            return postsRouter.errorCase(errorCode, description)
            
        case .comments(let commentRouter):
            return commentRouter.errorCase(errorCode, description)
        }
    }
}
// 공동에러
extension NetworkRouter: CommonError {
    
    static func commonTest(status: Int) -> NetworkError? {
        switch status {
        case 420, 429, 444, 500:
            return .commonError(status: status)
        default:
            return nil
        }
    }
    
}
extension NetworkRouter {
    static func jsEncoding(_ target: Encodable) -> Data? {
        
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

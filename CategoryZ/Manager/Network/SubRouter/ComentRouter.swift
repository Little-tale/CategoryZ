//
//  ComentRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import Foundation
import Alamofire

enum ComentRouter {
    case commentsWrite(query: ComentWriteQuery, postId: String)
    
}


extension ComentRouter: TargetType {
    
    var baseUrl: URL? {
        return URL(string: APIKey.baseURL.rawValue)
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .commentsWrite:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .commentsWrite(_, let postId):
            
            return PathRouter.posts.path + "/\(postId)" + "/\(PathRouter.comments.path)"
        }
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .commentsWrite:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .commentsWrite:
            return [
                NetHTTPHeader.contentType.rawValue :
                    NetHTTPHeader.json.rawValue,
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .commentsWrite:
            return nil
        }
    }
    
    var version: String {
        switch self {
        case .commentsWrite:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .commentsWrite(let query,_):
            NetworkRouter.jsEncoding(query)
        }
    }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .commentsWrite:
            return .commentsWriteError(statusCode: errorCode, description: description)
        }
    }
    
    
}



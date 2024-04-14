//
//  ComentRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import Foundation
import Alamofire

enum CommentRouter {
    case commentsWrite(query: CommentWriteQuery, postId: String)
    case commentModify(query: CommentWriteQuery, postId: String, commentsId:String)
    case commentDelete(postId: String, commentsId:String)
}


extension CommentRouter: TargetType {
    
    var baseUrl: URL? {
        return URL(string: APIKey.baseURL.rawValue)
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .commentsWrite:
            return .post
        case .commentModify:
            return .put
        case .commentDelete:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .commentsWrite(_, let postId):
            return PathRouter.posts.path + "/\(postId)" + "/\(PathRouter.comments.path)"
        case .commentModify(_, let postId, let commentsId), .commentDelete(let postId, let commentsId):
            return PathRouter.posts.path + "/\(postId)" + "/\(PathRouter.comments.path)" + "/\(commentsId)"
        }
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .commentsWrite, .commentModify, .commentDelete:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .commentsWrite, .commentModify:
            return [
                NetHTTPHeader.contentType.rawValue :
                    NetHTTPHeader.json.rawValue,
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue
            ]
        case .commentDelete:
            return [
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .commentsWrite, .commentModify, .commentDelete:
            return nil
        }
    }
    
    var version: String {
        switch self {
        case .commentsWrite, .commentModify, .commentDelete:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .commentsWrite(let query,_), .commentModify(let query,_,_):
            return NetworkRouter.jsEncoding(query)
        case .commentDelete:
            return nil
        }
    }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .commentsWrite:
            return .commentsWriteError(statusCode: errorCode, description: description)
            
        case .commentModify, .commentDelete:
            return .commentsModifyError(statusCode: errorCode, description: description)
        }
    }
}



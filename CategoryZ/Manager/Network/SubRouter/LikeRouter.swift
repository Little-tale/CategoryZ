//
//  LikeRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import Foundation
import Alamofire

enum LikeRouter {
    case like(query: LikeQueryModel, postId: String)
    case findLikedPost(next: String?, limit: String?)
}

extension LikeRouter : TargetType {
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .like:
            return .post
        case .findLikedPost:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .like(_, let postId):
            return PathRouter.posts.path + "/\(postId)/like"
        case .findLikedPost:
            return PathRouter.posts.path + "/likes/me"
        }
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .like, .findLikedPost:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .like, .findLikedPost:
            return [
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .like:
            return nil
        case .findLikedPost(let next, let limit):
            return [
                URLQueryItem(name: "next", value: next),
                URLQueryItem(name: "limit", value: limit)
            ]
        }
    }
    
    var version: String {
        switch self {
        case .like, .findLikedPost:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .like(let query,_):
            return NetworkRouter.jsEncoding(query)
        case .findLikedPost:
            return nil
        }
    }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        print("like Router Error : \(errorCode),\(description)")
        switch self {
        case .like:
            return .likeError(statusCode: errorCode, description: description)
        case .findLikedPost:
            return .postReadError(statusCode: errorCode, description: description)
        }
    }

}

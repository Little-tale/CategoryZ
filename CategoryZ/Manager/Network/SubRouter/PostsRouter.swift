//
//  PostRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/12/24.
//

import Foundation
import Alamofire

enum PostsRouter {
    case imageUpload
    case postWrite(query: PostsQeuryType)
    case postRead(next: String? = nil, limit: String, productId: String? = nil)
    case postModify(query: PostsQeuryType, postID: String)
    case selectPostRead(postID: String)
    case postDelete(postID: String)
    /// 다른 유저가 작성한 포스터 혹은 자신의 포스터들
    case userCasePostRead(userId: String,next: String? = nil, limit: String, productId: String? = nil)
    /// 새롭게 해쉬태그 기능이 추가되었습니다.
    case findHashTag(
        next: String? = nil,
        limit: String,
        productId: String? = nil,
        hashTag: String?
    )
}

extension PostsRouter: TargetType {

    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .imageUpload, .postWrite:
            return .post
    
        case    .postRead,
                .selectPostRead,
                .userCasePostRead,
                .findHashTag:
            
            return .get
            
        case .postModify:
            return .put
            
        case .postDelete:
            return .delete
            
        }
    }
    
    var path: String {
        switch self {
        case .imageUpload:
            return PathRouter.posts.path + "/files"
            
        case .postWrite, .postRead:
            return PathRouter.posts.path
            
        case .postModify(_, let postId),
                .selectPostRead(let postId),
                .postDelete(let postId):
            return PathRouter.posts.path + "/\(postId)"
            
        case .userCasePostRead(let userId,_,_,_):
            return PathRouter.posts.path + "/users/\(userId)"
            
        case .findHashTag:
            return PathRouter.hashTag.path
        }
        
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .imageUpload, .postWrite, .postRead, .postModify, .selectPostRead, .postDelete, .userCasePostRead, .findHashTag:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .imageUpload:
            return [
                NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                NetHTTPHeader.contentType.rawValue : NetHTTPHeader.multipart.rawValue
            ]
        case .postWrite, .postModify, .findHashTag:
            return [
                NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                NetHTTPHeader.contentType.rawValue: NetHTTPHeader.json.rawValue
            ]
            
        case .postRead, .selectPostRead, .postDelete, .userCasePostRead:
            return [
                NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .imageUpload, .postWrite, .postModify, .selectPostRead, .postDelete:
            return nil
        case .postRead(let next, let limit, let product) , .userCasePostRead(_, let next, let limit, let product):
            
           return createPostQueryItems(next: next, limit: limit, product: product)
            
        case .findHashTag(let next, let limit, let product, let hashTag) :
            
            var items = createPostQueryItems(next: next, limit: limit, product: product)
            items.append(URLQueryItem(name: "hashTag", value: hashTag))
            
            return items
        }
    }
    
    var version: String {
        switch self {
        case .imageUpload, .postWrite, .postRead, .postModify, .selectPostRead, .postDelete, .userCasePostRead, .findHashTag:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .imageUpload, .postRead, .selectPostRead, .postDelete, .userCasePostRead, .findHashTag:
            return nil
        case .postWrite(let query), .postModify(let query, _):
            return NetworkRouter.jsEncoding(query)
        }
    }

    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .imageUpload:
            return .imageUploadError(statusCode: errorCode, description: description)
        case .postWrite:
            return .postWriteError(statusCode: errorCode, description: description)
        case .postRead:
            return .postReadError(statusCode: errorCode, description: description)
        case .postModify:
            return .postModifyError(statusCode: errorCode, description: description)
        case .selectPostRead:
            return .selectPostError(statusCode: errorCode, description: description)
        case .postDelete:
            return .postDeletError(statusCode: errorCode, description: description)
            
        case .userCasePostRead:
            return .postReadError(statusCode: errorCode, description: description)
            
        case .findHashTag:
            return .postReadError(statusCode: errorCode, description: description)
        }
    }
    
}

extension PostsRouter {
    
    private
    func createPostQueryItems(next: String?, limit: String?, product: String?) -> [URLQueryItem] {
        var items = [
            URLQueryItem(name: "next", value: next),
            URLQueryItem(name: "limit", value: limit)
        ]
        if let product = product {
            items.append(URLQueryItem(name: "product_id", value: product))
        }
        return items
    }
}

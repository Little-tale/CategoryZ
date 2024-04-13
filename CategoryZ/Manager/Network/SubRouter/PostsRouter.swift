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
    case postRead(next: String? = nil, limit: String, productId: String)
    case postModify(query: PostsQeuryType, postID: String)
    case selectPostRead(postID: String)
//    case postModify
//    case postDelete
//    case userCasePostRead
}

extension PostsRouter: TargetType {
    
    var baseUrl: URL? {
        return URL(string: APIKey.baseURL.rawValue)
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .imageUpload, .postWrite:
            return .post
            
        case .postRead, .selectPostRead:
            return .get
            
        case .postModify:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .imageUpload:
            return PathRouter.posts.path + "/files"
        case .postWrite, .postRead:
            return PathRouter.posts.path
        case .postModify(_, let postId), .selectPostRead(let postId):
            return PathRouter.posts.path + "/\(postId)"
        }
        
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .imageUpload, .postWrite, .postRead, .postModify, .selectPostRead:
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
        case .postWrite, .postModify:
            return [
                NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                NetHTTPHeader.contentType.rawValue: NetHTTPHeader.json.rawValue
            ]
            
        case .postRead, .selectPostRead:
            return [NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .imageUpload, .postWrite, .postModify, .selectPostRead:
            return nil
        case .postRead(let next, let limit, let product):
            return [
                URLQueryItem(name: "next", value: next),
                URLQueryItem(name: "limit", value: limit),
                URLQueryItem(name: "product_id", value: product)
            ]
        }
    }
    
    var version: String {
        switch self {
        case .imageUpload, .postWrite, .postRead, .postModify, .selectPostRead:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .imageUpload, .postRead, .selectPostRead:
            return nil
        case .postWrite(let query), .postModify(let query, _):
            return jsEncoding(query)
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
        case .selectPostRead(postID: let postID):
            return .postModifyError(statusCode: errorCode, description: description)
        }
    }
    
}


extension PostsRouter {
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




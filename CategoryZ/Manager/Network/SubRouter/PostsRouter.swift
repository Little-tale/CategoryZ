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
//    case postWrite
//    case postRead
//    case selectPostRead
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
        case .imageUpload:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .imageUpload:
            PathRouter.posts.path + "/files"
        }
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .imageUpload:
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
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .imageUpload:
            return nil
        }
    }
    
    var version: String {
        switch self {
        case .imageUpload:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .imageUpload:
            return nil
        }
    }

    
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .imageUpload:
            return .imageUploadError(statusCode: errorCode, description: description)
        }
    }
    
}





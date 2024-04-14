//
//  FollowRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import Foundation
import Alamofire

enum FollowRouter {
    case follow(userId: String)
    case unFollow(userId: String)
}

extension FollowRouter: TargetType {
    var baseUrl: URL? {
        return URL(string: APIKey.baseURL.rawValue)
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .follow:
            return .post
        case .unFollow:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .follow(let userId),.unFollow(let userId):
            return PathRouter.follow.path + "/\(userId)"
        }
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .follow, .unFollow:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .follow, .unFollow:
            return [
                NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .follow, .unFollow:
            return nil
        }
    }
    
    var version: String {
        switch self {
        case .follow, .unFollow:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .follow, .unFollow:
            return nil
        }
    }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .follow:
            return .followError(statusCode: errorCode, description: description)
        case .unFollow:
            return .followError(statusCode: errorCode, description: description)
        }
    }
    
    
}

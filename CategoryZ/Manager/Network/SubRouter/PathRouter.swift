//
//  TokkenRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/12/24.
//

import Foundation



enum PathRouter {
    case users
    case validation
    case posts
    case auth
    case follow
    case usersMe
    case comments
    
    var path: String {
        switch self {
        case .users:
            return "users"
        case .validation:
            return "validation"
        case .posts:
            return "posts"
        case .follow:
            return "follow"
        case .usersMe:
            return "users/me"
        case .auth:
            return "auth"
        case .comments:
            return "comments"
        }
    }
}

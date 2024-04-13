//
//  NetWorkModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/9/24.
//

import Foundation

/// 로그인 모델
struct LoginModel: Decodable {
    let user_id: String
    let email: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
}
/// 회원가입 모델
struct JoinModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
}

/// 이메일 중복 결과 모델
struct EmailVaildModel: Decodable {
    let message: String
}

/// 리프레시
struct RefreshModel: Decodable {
    let accessToken: String
}

/// 삭제된 유저 모델
struct UserWithDraw: Decodable {
    let user_id: String
    let email: String
    let nick: String
}


/// 이미지 데이터 모델
struct imageDataModel: Decodable {
    let files: [String]
}


///MARK:  포스트 데이터 모델
struct SNSMainModel: Decodable {
    let data: [SnsModel]
    let nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

// MARK: 포스트 모델
struct PostModel: Decodable {
    let postID, title, content: String
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes, comments: [String]

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case title, content, createdAt, creator, files, likes, comments
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postID = try container.decodeIfPresent(String.self, forKey: .postID) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title)  ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content)  ?? ""
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(Creator.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.likes = try container.decode([String].self, forKey: .likes)
        self.comments = try container.decode([String].self, forKey: .comments)
    }
}

struct PostReadMainModel: Decodable {
    let data: [SnsModel]
    let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct SnsModel: Decodable {
    let postId: String
    let productId: String
    let title: String
    let content: String
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes: [String]
    let hashTags: [String]
    let comments: [String]
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case productId = "product_id"
        case title
        case content
        case createdAt = "createdAt"
        case creator
        case files
        case likes
        case hashTags
        case comments
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.productId = try container.decodeIfPresent(String.self, forKey: .productId) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(Creator.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.likes = try container.decode([String].self, forKey: .likes)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        self.comments = try container.decode([String].self, forKey: .comments)
    }
}

struct Creator: Decodable {
    let userID, nick: String // 유저이름 , 유저 아이디
    let profileImage: String? // 프로필 이미지들

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}

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
}

struct SnsModel: Decodable {
    let postID: String // 포스트 아이디
    let title: String // 타이틀
    let content: String // 섭타이틀
    let createdAt: String // 생성일
    let creator: Creator
    let files: [String]?
    let likes: [String]
    let comments: [String]
   
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case title, content, createdAt, creator, files, likes, comments
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

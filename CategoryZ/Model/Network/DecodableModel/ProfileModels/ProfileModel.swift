//
//  ProfileModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

// 프로필 모델
struct ProfileModel: Decodable {
    let userID: String
    let email: String
    let nick: String
    let phoneNum: String
    let followers, following: [Creator]
    let profileImage: String
    let posts: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nick, profileImage, followers, following, posts
        case phoneNum
    }
    
    init() {
        self.userID = ""
        self.email = ""
        self.nick = ""
        self.phoneNum = ""
        self.followers = []
        self.following = []
        self.profileImage = ""
        self.posts = []
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
        self.followers = try container.decode([Creator].self, forKey: .followers)
        self.following = try container.decode([Creator].self, forKey: .following)
        self.posts = try container.decode([String].self, forKey: .posts)
        self.phoneNum = try container.decodeIfPresent(String.self, forKey: .phoneNum) ?? ""
    }
}

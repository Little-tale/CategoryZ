//
//  JoinModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

/// 회원가입 모델
struct JoinModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let phoneNum: String
    
    enum CodingKeys: CodingKey {
        case user_id
        case email
        case nick
        case phoneNum
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.email = try container.decode(String.self, forKey: .email)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.phoneNum = try container.decodeIfPresent(String.self, forKey: .phoneNum) ?? ""
    }
    
}

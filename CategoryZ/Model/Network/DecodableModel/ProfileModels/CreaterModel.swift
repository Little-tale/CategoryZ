//
//  CreaterModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation
// 만든이
final class Creator: Decodable , Equatable{

    let userID, nick: String // 유저이름 , 유저 아이디
    let profileImage: String? // 프로필 이미지들
    
    var isFollow = false
    
    let uuid = UUID()
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
    }
    
    static func == (lhs: Creator, rhs: Creator) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    init(userID: String, nick: String, profileImage: String?, isFollow: Bool = false) {
        self.userID = userID
        self.nick = nick
        self.profileImage = profileImage
        self.isFollow = isFollow
    }
}

//
//  FollowFollwingMOdel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

/// 팔로우 팔로잉 모델
struct FollowModel: Decodable {
    let nick: String // 이름
    let opponentNick: String // 상대 이름
    let followingStatus: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case nick
        case opponentNick = "opponent_nick"
        case followingStatus = "following_status"
    }
}


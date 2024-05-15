//
//  chatsRoomQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/15/24.
//

import Foundation

struct ChatsRoomQuery: Encodable {
    /// 채팅 상대방 유저 아이디  -> Creator <-
    let opponent_id: String
}

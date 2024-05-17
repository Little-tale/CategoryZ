//
//  ChatRoom.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/15/24.
//

import Foundation

struct ChatRoomModel: Decodable {
    let roomID, createdAt, updatedAt: String
    let participants: [Creator]
    let lastChat: ChatModel?

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
}

//
//  ChatModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/15/24.
//

import Foundation

struct ChatModel: Decodable {
    let chatID, roomID, createdAt: String
    let content: String?
    let sender: Creator
    let files: [String]

    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case roomID = "room_id"
        case content, createdAt, sender, files
    }
}

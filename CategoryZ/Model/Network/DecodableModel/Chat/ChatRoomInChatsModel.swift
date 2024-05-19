//
//  ChatRoomInChatsModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation

final class ChatRoomInChatsModel: Decodable {

    let chatList: [ChatModel] // 왼만하면 무조건이네...
    
    init(chatList: [ChatModel]) {
        self.chatList = chatList
    }
    
    enum CodingKeys: String, CodingKey {
        case chatList = "data"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatList = try container.decode([ChatModel].self, forKey: .chatList)
    }
}

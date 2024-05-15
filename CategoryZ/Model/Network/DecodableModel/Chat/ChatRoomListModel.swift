//
//  ChatRoomList.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/15/24.
//

import Foundation

struct ChatRoomListModel: Decodable {
    let chatRoomList: [ChatRoom]
    
    init(chatRoomList: [ChatRoom]) {
        self.chatRoomList = chatRoomList
    }
    
    enum CodingKeys: String, CodingKey {
        case chatRoomList = "data"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatRoomList = try container.decode([ChatRoom].self, forKey: .chatRoomList)
    }
}


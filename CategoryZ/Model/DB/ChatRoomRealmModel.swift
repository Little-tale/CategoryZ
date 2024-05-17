//
//  ChatRoomModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation
import RealmSwift

final class ChatRoomRealmModel: Object {
    
    @Persisted(primaryKey: true)
    var roomId: String
    
    @Persisted
    var createAt: String
    
    @Persisted
    var updateAt: String
    
    @Persisted
    var otherUserName: String
    
    @Persisted
    var otherUserProfile: String?
    
    @Persisted
    var chatBoxs: List<ChatBoxModel>
    
    init(roomId: String, createAt: String, updateAt: String, otherUserName: String, otherUserProfile: String? = nil, chatBoxs: List<ChatBoxModel>) {
        self.init()
        
        self.roomId = roomId
        self.createAt = createAt
        self.updateAt = updateAt
        self.otherUserName = otherUserName
        self.otherUserProfile = otherUserProfile
        self.chatBoxs = chatBoxs
    }
    
}

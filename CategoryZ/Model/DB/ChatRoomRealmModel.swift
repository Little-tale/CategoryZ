//
//  ChatRoomModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation
import RealmSwift

final class ChatRoomRealmModel: Object, RealmFindType {
    
    @Persisted(primaryKey: true)
    var id: String
    
    
    @Persisted
    var createAt: Date
    
    @Persisted
    var updateAt: Date?
    
    @Persisted
    var otherUserName: String
    
    @Persisted
    var otherUserProfile: String?
    
    @Persisted
    var chatBoxs: List<ChatBoxRealmModel>
    
    @Persisted
    var lastChatWatch: Date
    
    @Persisted
    var serverLastChat: String
    
    @Persisted
    var ifNew: Bool
    
    @Persisted
    var lastChatDate: Date? // 채팅실제와 분리위해
    
    convenience
    init(
        roomId: String,
        createAt: Date,
        updateAt: Date?,
        otherUserName: String,
        otherUserProfile: String? = nil,
        lastChatWatch: Date
    ) {
        self.init()
        
        self.id = roomId
        self.createAt = createAt
        self.updateAt = updateAt
        self.otherUserName = otherUserName
        self.otherUserProfile = otherUserProfile
        self.lastChatWatch = lastChatWatch
        self.serverLastChat = ""
        self.ifNew = false
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

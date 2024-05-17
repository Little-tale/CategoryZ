//
//  ChatBoxModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation
import RealmSwift
/*
 현재 해당 모델의 LinkedList 부모를 알필요는 없다고 판단하여 없앱니다.
 */
final class ChatBoxModel: Object {
    
    @Persisted(primaryKey: true)
    var chatId: String
    
    @Persisted
    var contentText: String?
    
    // 만약 이미지URL이 존재할 경우 contentText 는 생략 (다른앱과 충돌 예상 지점
    @Persisted
    var imageFiles: List<String>
    
    @Persisted
    var isMe: Bool
    
    convenience
    init(id: String, contentText: String? = nil, imageFiles: [String], isMe: Bool) {
        self.init()
        self.chatId = id
        self.contentText = contentText
        self.imageFiles.append(objectsIn: imageFiles)
        self.isMe = isMe
    }
}

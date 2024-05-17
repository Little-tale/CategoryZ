//
//  ChatBoxModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/17/24.
//

import Foundation
import RealmSwift

final class ChatBoxModel: Object {
    
    @Persisted(primaryKey: true)
    var id: String
    
    @Persisted
    var contentText: String?
    
    // 만약 이미지URL이 존재할 경우 contentText 는 생략 (다른앱과 충돌 예상 지점
    @Persisted
    var imageFiles: List<String?>
    
    @Persisted
    var isMe: Bool
    
    convenience
    init(id: String, contentText: String? = nil, imageFiles: List<String?>, isMe: Bool) {
        self.init()
        self.id = id
        self.contentText = contentText
        self.imageFiles = imageFiles
        self.isMe = isMe
    }
}

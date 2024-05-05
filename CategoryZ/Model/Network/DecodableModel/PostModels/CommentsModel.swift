//
//  CommentsModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

/// 댓글 모델
final class CommentsModel: Decodable {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: Creator
    
    var postId = ""
    var currentRow = 0
    var isUserMe = false
    
    enum CodingKeys:String, CodingKey {
        case commentID = "comment_id"
        case content
        case createdAt
        case creator
    }
}

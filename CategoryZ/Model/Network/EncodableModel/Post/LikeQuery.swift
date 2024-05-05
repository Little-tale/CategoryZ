//
//  LikeQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

/// 좋아요 쿼리 (CODABLE)
struct LikeQueryModel: Codable {
    var like_status: Bool
    var currentRow = 0
    
    init(like_status: Bool? = false) {
        self.like_status = like_status ?? false
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.like_status = try container.decode(Bool.self, forKey: .like_status)
    }
}

//
//  MainPostQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

protocol PostsQeuryType: Encodable {
    // 타이틀
    var title: String { get set }
    // 게시글 섭 타이틀
    var content: String { get set }
    
    var content2: String { get set }
    
    var content3: String { get set }
    
    var product_id: String { get set }
    
    var files: [String]? { get set }
    
}

/// 포스트 쿼리
struct MainPostQuery: PostsQeuryType {
   
    /// 타이틀
    var title: String
    /// 게시글 섭 타이틀
    var content: String
    /// 사용 X
    var content2: String
    /// 사용 X
    var content3: String
    
    var product_id: String
    
    var files: [String]?
}

//
//  NetWorkQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation

// 요청 바디

// HTTP POST
/// 로그인 쿼리 ( 요청바디 )
struct LoginQuery: Encodable {
    let email: String
    let password: String
}

/// 회원가입 쿼리 ( 요청바디 )
struct JoinQuery: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String?
    ///let birthDay: String?
}

/// 이메일 중복 확인 ( 요청바디 )
struct EmailValidationQuery: Encodable {
    let email: String
}

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




/// 댓글 작성 쿼리
struct CommentWriteQuery: Encodable {
    let content: String
}

/// 좋아요 쿼리 (CODABLE)
struct LikeQueryModel: Codable {
    var like_status: Bool
    
    init(like_status: Bool? = false) {
        self.like_status = like_status ?? false
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.like_status = try container.decode(Bool.self, forKey: .like_status)
    }
}


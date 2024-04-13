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
    // let birthDay: String?
}

/// 이메일 중복 확인 ( 요청바디 )
struct EmailValidationQuery: Encodable {
    let email: String
}



/// 포스트 쿼리
struct MainPostQuery: Encodable {
    // 타이틀
    var title: String
    // 게시글 섭 타이틀
    var content: String
    
    var product_id = "CategoryZ_Test_Server"
    
    var files: [String]?
    
}


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



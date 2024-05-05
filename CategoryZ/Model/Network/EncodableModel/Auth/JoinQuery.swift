//
//  JoinQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation
/// 회원가입 쿼리 ( 요청바디 )
struct JoinQuery: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String?
    ///let birthDay: String?
}

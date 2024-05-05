//
//  LoginQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

// HTTP POST
/// 로그인 쿼리 ( 요청바디 )
struct LoginQuery: Encodable {
    let email: String
    let password: String
}

//
//  NetWorkQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation

// 요청 바디

// HTTP POST
struct LoginQuery: Encodable {
    let email: String
    let password: String
}

struct JoinQuery: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String?
    let birthDay: String?
}

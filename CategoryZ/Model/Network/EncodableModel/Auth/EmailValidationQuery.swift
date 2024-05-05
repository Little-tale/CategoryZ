//
//  EmailValidationQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

/// 이메일 중복 확인 ( 요청바디 )
struct EmailValidationQuery: Encodable {
    let email: String
}

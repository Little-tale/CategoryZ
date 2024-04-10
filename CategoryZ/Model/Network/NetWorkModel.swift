//
//  NetWorkModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/9/24.
//

import Foundation

/// 로그인 모델
struct LoginModel: Decodable {
    let accessToken: String
    let refreshToken: String
}
/// 회원가입 모델
struct JoinModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
}

/// 이메일 중복 결과 모델
struct EmailVaildModel: Decodable {
    let message: String
}

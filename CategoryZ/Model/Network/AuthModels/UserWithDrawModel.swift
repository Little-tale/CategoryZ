//
//  UserWithDrawModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation


/// 삭제된 유저 모델
struct UserWithDraw: Decodable {
    let user_id: String
    let email: String
    let nick: String
}

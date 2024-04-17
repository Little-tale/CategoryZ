//
//  CursurModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import Foundation

struct cursurModel {
    let next: String? // 처음 요청시에는 빈값으로 요청
    let limit = "10" // 한페이지당 보일 갯수
    let productId: String // 프로덕트 아이디 내입장에선 필수
}

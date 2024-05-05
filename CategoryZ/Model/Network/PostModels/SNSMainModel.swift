//
//  SNSMainModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

///MARK:  포스트 데이터 모델
struct SNSMainModel: Decodable {
    let data: [SNSDataModel]
    let nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

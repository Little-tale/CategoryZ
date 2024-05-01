//
//  PaymentsModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import Foundation

// 결제 영수증 검증
struct PaymentsModel: Codable {
    
    let impUID: String
    let postID: String
    let productName: String
    var price: Int
    
    enum CodingKeys: String, CodingKey {
        case impUID = "imp_uid"
        case postID = "post_id"
        case productName
        case price
    }
    
    init(impUID: String, postID: String, productName: String, price: Int) {
        self.impUID = impUID
        self.postID = postID
        self.productName = productName
        self.price = price
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.impUID = try container.decode(String.self, forKey: .impUID)
        self.postID = try container.decode(String.self, forKey: .postID)
        self.productName = try container.decode(String.self, forKey: .productName)
        self.price = try container.decode(Int.self, forKey: .price)
    }
    
    
}

//
//  PatmentsListModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import Foundation

/// 해당 모델을 통해 통신 하여야 합니다.
struct PaymentsListModel: Decodable {
    let dataList: [PaymentData]
}

struct PaymentData: Decodable {
    
    /// 구매 아이디
    let paymentID: String
    /// 구매자 아이디
    let buyerID: String
    /// 포스트 아이디
    let postID: String
    ///
    let merchantUid: String
    /// 상품 이름
    let productName: String
    /// 가격
    let price: Int
    /// 결제 날짜
    let paidAt: String
    
    enum CodingKeys: String, CodingKey {
        case paymentID = "payment_id"
        case buyerID = "buyer_id"
        case postID = "post_id"
        case merchantUid = "merchant_uid"
        case productName, price, paidAt
    }
}

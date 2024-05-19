//
//  ImageCachingType.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/8/24.
//

import UIKit.UIImageView
import Kingfisher


// 트러블 슈팅
//    이미지 캐싱 전략을 수정합니다.
//    1. 이미지뷰의 사이즈 별로 캐싱 하게 하였으나.... 만약 오차가 1이라도 나게 된다면 엄청난 메모리 리스크를 감수해야 하게 되더군요
//    2. 그리하여 이미지 캐싱 사이즈를 이넘화 하여 적용하게 수정할것입니다.

protocol ImageCachingType {
    
    func downloadImage(imageUrl: String?, resizeCase: ImageCachingCase,_ defaultImage: UIImage?)
}

enum ImageCachingCase {
    case high
    case middle
    case low
    case superLow
    
    var size: CGSize {
        switch self {
        case .high:
            return .init(width: 250, height: 250)
        case .middle:
            return .init(width: 150, height: 150)
        case .low:
            return .init(width: 100, height: 100)
        case .superLow:
            return .init(width: 50, height: 50)
        }
    }
}

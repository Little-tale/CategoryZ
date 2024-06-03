//
//  ProductID.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import Foundation
import UIKit.UIImage

enum ProductID: String, CaseIterable {
    case dailyRoutine = "CategoryZ_dailyRoutine"
    case fashion = "CategoryZ_fashion"
    case pet = "CategoryZ_pet"
    case talent = "CategoryZ_telent"
    case song = "CategoryZ_song"
    case book = "CategoryZ_books"
    case healthKing = "myLoveGym"
    
    static let userProduct = "CategoryZ_UserDonate"
    
    var identi: String {
        return rawValue
    }
    
    var image: UIImage {
        switch self {
        case .dailyRoutine:
            return .daily
        case .fashion:
            return .fashion
        case .pet:
            return .pet
        case .talent:
            return .talent
        case .song:
            return .song
        case .book:
            return .book
        case .healthKing:
            return JHImage.health
        }
    }
    
    var title: String {
        return switch self {
        case .dailyRoutine:
             "일상"
        case .fashion:
             "패션"
        case .pet:
             "애완동물"
        case .talent:
             "연예인"
        case .song:
             "Sing"
        case .book:
             "독서"
        case .healthKing:
             "헬스킹"
        }
    }
    
    var index: Int {
        return ProductID.allCases.firstIndex(of: self) ?? 0
    }
    
}


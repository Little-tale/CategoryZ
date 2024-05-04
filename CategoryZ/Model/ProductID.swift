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
        }
    }
    
    var title: String {
        switch self {
        case .dailyRoutine:
            return "일상"
        case .fashion:
            return "패션"
        case .pet:
            return "애완동물"
        case .talent:
            return "연예인"
        case .song:
            return "Sing"
        case .book:
            return "독서"
        }
    }
    
    var index: Int {
        return ProductID.allCases.firstIndex(of: self) ?? 0
    }
    
}


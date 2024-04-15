//
//  ProductID.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import Foundation
import UIKit.UIImage

enum ProductID: CaseIterable {
    case dailyRoutine
    case fashion
    case pet
    
    var identi: String {
        switch self {
        case .dailyRoutine:
            return "CategoryZ_dailyRoutine"
        case .fashion:
            return "CategoryZ_fashion"
        case .pet:
            return "CategoryZ_pet"
        }
    }
    
    var image: UIImage {
        switch self {
        case .dailyRoutine:
            return .daily
        case .fashion:
            return .fashion
        case .pet:
            return .pet
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
        }
    }
}

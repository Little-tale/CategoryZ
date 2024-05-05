//
//  PriceModel .swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import Foundation


enum PriceModel: Int, CaseIterable {
    case thousand1 = 1000
    case thousand2 = 2000
    case thousand3 = 3000
    case thousand4 = 4000
    case thousand5 = 5000
    case thousand6 = 6000
    case thousand7 = 7000
    case thousand8 = 8000
    case thousand9 = 9000
    case thousand10 = 10000
}


extension PriceModel {
    var price: String {
        return "\(self.rawValue)원"
    }
}


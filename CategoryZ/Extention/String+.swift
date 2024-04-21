//
//  String+.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import Foundation


extension String {
    
    var asStringURL: URL? {
        return URL(string: self)
    }
}

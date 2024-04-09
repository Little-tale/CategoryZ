//
//  NetWorkQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation


// HTTP POST
struct LoginQuery: Encodable {
    let email: String
    let password: String
}

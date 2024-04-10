//
//  NetHTTPHeader.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation

/*
 공지사항
 모든 요청에는 SeSackey 가 필요헙니다.
 - 회원 요청을 제외한 모든 요청에는 Autorization이 필요합니다.
 */
enum NetHTTPHeader: String {
    
    case authorization = "Authorization"
    
    case sesacKey = "SesacKey"
    
    case refresh = "Refresh"
    
    case contentType = "Content-Type"
    
    case json = "application/json"
    
}

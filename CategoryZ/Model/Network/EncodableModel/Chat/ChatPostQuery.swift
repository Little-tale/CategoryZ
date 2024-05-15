//
//  ChatPostQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/15/24.
//

import Foundation

struct ChatPostQuery: Encodable {
    /// 채팅 본문
    let content: String
    /// 파일들
    let files: [String]?
}

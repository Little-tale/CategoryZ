//
//  ChatPostQuery.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/15/24.
//

import Foundation

struct ChatPostQuery: Encodable {
    /// 채팅 본문 // 만약 나의 앱이 아닌 곳에서 왔을경우 대비
    let content: String?
    /// 파일들
    let files: [String]?
}

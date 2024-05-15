//
//  ChatRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import Foundation
import Alamofire

enum ChatRouter {
    case createChatRoom(query: ChatsRoomQuery)
    
    /*
    
    case myChatRooms
    /// cursorDate -> UTC -> EX) 2024-05-06T05:13:54.357Z
    ///  But If you Don't return a value UTC Type -> 500Error
    case readChatingList(cursorDate: String, roomID: String)
    case postChat(roomID: String)
    case chatingImageUpload
     
     */
    
}

extension ChatRouter: TargetType {
    
    var method: HTTPMethod {
        switch self {
        case .createChatRoom:
             return .post
        }
    }
    
    var path: String {
        switch self {
        case .createChatRoom:
            return PathRouter.chat.path
        }
    }
    
    var parametters: Parameters? {
        switch self {
        case .createChatRoom:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .createChatRoom:
            return [
                NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                NetHTTPHeader.contentType.rawValue: NetHTTPHeader.json.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .createChatRoom:
            return nil
        }
    }
    
    var version: String {
        switch self {
        case .createChatRoom:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .createChatRoom(let query):
            return NetworkRouter.jsEncoding(query)
        }
    }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .createChatRoom:
            return .postWriteError(statusCode: errorCode, description: description)
        }
    }
}

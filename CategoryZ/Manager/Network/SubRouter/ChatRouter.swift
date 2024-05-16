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
    case myChatRooms
    case readChatingList(cursorDate: String, roomID: String)
    /*
   
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
        case .myChatRooms, .readChatingList:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .createChatRoom, .myChatRooms:
            return PathRouter.chat.path
        case .readChatingList(_, let roomID):
            return PathRouter.chat.path + "/\(roomID)"
        }
    }
    
    var parametters: Parameters? {
        switch self {
        case .createChatRoom, .myChatRooms, .readChatingList:
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
        case .myChatRooms, .readChatingList:
            return [
                NetHTTPHeader.sesacKey.rawValue :
                    APIKey.sesacKey.rawValue
            ]
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .createChatRoom, .myChatRooms:
            return nil
        case .readChatingList(let cursorDate, _):
            return [
                URLQueryItem(name: "cursor_date", value: cursorDate)
            ]
        }
    }
    
    var version: String {
        switch self {
        case .createChatRoom, .myChatRooms, .readChatingList:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .createChatRoom(let query):
            return NetworkRouter.jsEncoding(query)
        case .myChatRooms, .readChatingList:
            return nil
        }
    }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .createChatRoom:
            return .postWriteError(statusCode: errorCode, description: description)
        case .myChatRooms:
            return .usurWithDrawError(statusCode: errorCode, description: description)
        case .readChatingList(cursorDate: let cursorDate, roomID: let roomID):
            return .chatListError(statusCode: errorCode, description: description)
        }
    }
}
//
//  NetError.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation


enum NetworkError: Error {
    
    case loginError(statusCode: Int, description: String)
    
    
    case failMakeURLRequest
    case unknownError
}



extension NetworkError {
    
    var message: String {
        switch self {
        case .loginError(let statusCode, let description):
            switch statusCode {
            case 401:
                return "401 에러 메시지"
            case 402:
                return "402 에러 메시지"
            default:
                return "알수없는 에러"
            }
        case .failMakeURLRequest:
            return "URL Request Error"
        case .unknownError:
            return "알수 없는 에러임 잘 찾아봐야...."
        }
    }
    
}

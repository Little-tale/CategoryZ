//
//  NetError.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation


enum NetworkError: Error {
    /// 로그인 에러 처리
    case loginError(statusCode: Int, description: String)

    /// URLRequest 생성중 에러
    case failMakeURLRequest
    
    /// 무슨 에러인지 전혀 모를때
    case unknownError
    
    case commonError(status: Int)

}



extension NetworkError {
    
    /// 메시지를 보내고 싶을때
    var message: String {
        switch self {
        case .loginError(let statusCode, let description):
            switch statusCode {
            case 401:
                return "401 에러 메시지"
            case 402:
                return "402 에러 메시지"
            default:
                return "알수없는 에러 \(description)"
            }
            
        case .failMakeURLRequest:
            return "URL Request Error"
            
        case .unknownError:
            return "알수 없는 에러임 잘 찾아봐야...."
            
        case .commonError(let status):
            switch status{
            case 420 :
                return "SesacKey 에 키값이 없거나 틀린 경우입니다."
            case 429 :
                return "서버에 과호출을 하는 경우 입니다."
            case 444 :
                return "비정상 URL 을 통해 요청하신 경우 입니다."
            case 500 :
                return "비정상 요청 및 사전에 정의 되지 않는 에러가 발생한 경우"
            default :
                return "진짜 절대 나오면 안되는 에러"
            }
        }
    }
    
}

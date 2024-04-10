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

    /// 회원가입 에러
    case joinError(statusCode: Int, description: String)
    
    /// 이메일 중복확인 에러
    case emailValidError(statusCode: Int, description: String)
    
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
            case 400:
                return "필수값을 채워 주세요"
            case 401:
                return "계정을 확인하여 주세요"
            default:
                return "알수없는 에러 \(description)"
            }
            
        case .joinError(statusCode: let statusCode, description: let description):
            switch statusCode {
            case 400:
                return "필수값을 채워주세요"
            case 409:
                return "이미 가입한 유저입니다."
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .emailValidError(statusCode: let statusCode, description: let description):
            switch statusCode {
            case 400:
                return "필수값을 체워 주세요\nRequest body 필수 누락"
            case 409:
                return "사용이 불가한 이메일이에요"
            default :
                return "알수 없는 에러 \(description)"
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

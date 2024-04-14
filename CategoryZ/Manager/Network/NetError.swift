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
    
    /// 리프레시 토큰 에러
    case refreshTokkenError(statusCode: Int, description: String)
    
    /// 유저 정보 삭제 에러
    case usurWithDrawError(statusCode: Int, description: String)
    
    /// 이미지 업로드 에러
    case imageUploadError(statusCode: Int, description: String)
    
    /// 포스트 작성 에러
    case postWriteError(statusCode: Int, description: String)
    
    /// 포스트 조회 에러 + 다른혹은 자신의 포스트들 에러
    case postReadError(statusCode: Int, description: String)
    
    /// 포스트 수정 에러
    case postModifyError(statusCode: Int, description: String)
    
    /// 특정 포스트 에러
    case selectPostError(statusCode: Int, description: String)
    
    /// 포스트 제거 에러
    case postDeletError(statusCode: Int, description: String)
    
    /// 코멘트 작성 에러
    case commentsWriteError(statusCode: Int, description: String)
    
    /// 코멘트 수정 에러
    case commentsModifyError(statusCode: Int, description: String)
    
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
            
        case .refreshTokkenError(statusCode: let statusCode, description: let description):
            switch statusCode {
            case 401:
                return "인증할 수 없는 엑세스 토큰 입니다."
            case 403:
                return "접근 권한이 없습니다."
            case 418:
                return "리프레시 토큰이 만료 되었습니다.\n다시 로그인 하세요"
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .usurWithDrawError(let statusCode, let description) :
            switch statusCode {
            case 401 :
                return "유효하지 않은 토큰"
            case 403 :
                return "접근 권한이 없습니다."
            case 419 :
                return "엑세스 토큰이 만료되었습니다."
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .imageUploadError(let statusCode, let description) :
            switch statusCode {
            case 400 :
                return "잘못된 요청 혹은 필수값 없음"
            case 401 :
                return "인증할수 없는 엑세스 토큰"
            case 403:
                return "접근 권한이 없습니다."
            case 419:
                return "엑세스 토큰 만료"
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .postWriteError(let statusCode, let description) :
            switch statusCode {
            case 401 :
                return "인증할수 없는 엑세스 토큰"
            case 403 :
                return "접근 권한이 없습니다."
            case 410 :
                return "생성된 게시글이 없거나 서버 장애"
            case 419 :
                return "엑세스 토큰이 만료되었습니다."
            default :
                return "알수 없는 에러 \(description)"
            }
        case .postReadError(let statusCode, let description) :
            switch statusCode {
            case 400:
                return "잘못된 요청입니다."
            case 401:
                return "인증할 수 없는 엑세스 토큰입니다."
            case 403:
                return "접근 권한이 없습니다."
            case 419:
                return "엑세스 토큰이 만료되었습니다."
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .postModifyError(let statusCode, let description):
            switch statusCode {
            case 401:
                return "인증할 수 없는 엑세스 토큰입니다."
            case 403:
                return "접근 권한이 없습니다."
            case 410:
                return "수정할 게시글을 찾을수 없습니다."
            case 419:
                return "엑세스 토큰이 만료되었습니다."
            case 445:
                return "게시글 수정 권한이 없습니다."
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .selectPostError(let statusCode, let description):
            switch statusCode {
            case 400:
                return "잘못된 요청입니다."
            case 401:
                return "인증할 수 없는 엑세스 토큰입니다."
            case 403:
                return "접근 권한이 없습니다."
            case 419:
                return "엑세스 토큰이 만료되었습니다."
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .postDeletError(let statusCode, let description):
            switch statusCode {
            case 403:
                return "접근 권한이 없습니다."
            case 410:
                return "수정할 게시글을 찾을수 없습니다."
            case 419:
                return "엑세스 토큰이 만료되었습니다."
            case 445:
                return "게시글 삭제 권한이 없습니다."
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .commentsWriteError(let statusCode, let description):
            switch statusCode {
            case 400:
                return "필수 누락입니다!"
            case 401:
                return "인증할 수 없는 엑세스 토큰입니다."
            case 403:
                return "접근 권한이 없습니다."
            case 410:
                return "댓글을 추가할 게시글을 찾을수 없거나 생성된 댓글이 없습니다."
            case 419:
                return "엑세스 토큰이 만료되었습니다."
            default :
                return "알수 없는 에러 \(description)"
            }
            
        case .commentsModifyError(let statusCode, let description):
            switch statusCode {
            case 400:
                return "필수 누락입니다!"
            case 401:
                return "인증할 수 없는 엑세스 토큰입니다."
            case 403:
                return "접근 권한이 없습니다."
            case 410:
                return "(수정/삭제) 할 댓글을 찾을수 없습니다."
            case 419:
                return "엑세스 토큰이 만료되었습니다."
            case 445:
                return "댓글 수정/삭제 권한이 없습니다."
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
    /// 특정 상황의 에러 코드 별 대응 준비 ex) 418 이면 로그인 화면 전환
    var errorCode: Int {
        switch self {
        case .loginError(let statusCode, _):
            return statusCode
            
        case .joinError(let statusCode, _):
            return statusCode
            
        case .imageUploadError(let statusCode,_):
            return statusCode
            
        case .emailValidError(let statusCode, _):
            return statusCode
            
        case .refreshTokkenError(let statusCode, _):
            return statusCode
            
        case .commonError(let statusCode):
            return statusCode
            
        case .postReadError(let statusCode, _):
            return statusCode
            
        case .postWriteError(let statusCode, _):
            return statusCode
            
        case .postModifyError(let statusCode, _):
            return statusCode
            
        case .selectPostError(let statusCode, _):
            return statusCode
            
        case .postDeletError(let statusCode, _):
            return statusCode
            
        case .commentsWriteError(let statusCode,_):
            return statusCode
            
        case .commentsModifyError(let statusCode,_):
            return statusCode
            
        default :
            return 9999 // 9999일땐 URL 문제 혹은 해당 API 는 문제없음 모델 문제
        }
        
    }
    
}

enum RefreshError: Error {
    
    case cantReadTokken
    
    case reqeustFail
}

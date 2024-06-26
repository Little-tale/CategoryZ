//
//  AccessTokkenAdapter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation
import Alamofire


final class AccessTokkenAdapter: RequestInterceptor {
    
    private var refresing = false
    
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    private var retryCount = 3 {
        didSet {
            print("\(retryCount) 남음")
        }
    }
    private var retryCount2 = 1 {
        didSet{
            print("\(retryCount2) 남음")
        }
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
            
            // 현재 요청의 URL 경로를 확인
            if let urlPath = urlRequest.url?.path {
                
                // 요청 URL이 특정 경로를 포함하지 않는 경우에만 액세스 토큰 추가
                // 액세스 토큰이 필요하지 않은 API 경로 리스트
                let requiresToken = !NotNeedInterceptor.allCases.contains(where: { urlPath.contains($0.path) })
                
                if requiresToken,
                    let accessToken = TokenStorage.shared.accessToken {

                    urlRequest.headers.add(name: NetHTTPHeader.authorization.rawValue, value: accessToken)
                }
            }
            
            completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {

        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetryWithError(error))
            return
        }
        switch statusCode {
        case 419:
            requestsToRetry.append(completion)
            print("retry : statusCode: \(statusCode)")
            if !refresing {
                refresing = true

                NetworkManager.requestRefreshTokken { [weak self] isSuccess in
                    guard let self else { return }
                    
                    refresing = false
                    
                    switch isSuccess {
                    case .success(let success):
                        
                        TokenStorage.shared.accessToken = success.accessToken
                        
                        requestsToRetry.forEach { $0(.retryWithDelay(0.3)) }
                        
                    case .failure(let error):
                        print(error)
                        requestsToRetry.forEach { $0(.retryWithDelay(0.5)) }
                        if retryCount <= 0 {
                            requestsToRetry.forEach { $0(.doNotRetry) }
                            requestsToRetry.removeAll()
                        }
                        retryCount -= 1
                        
                    }
                    requestsToRetry.removeAll()
                }
            }
            
        case 418, 401:
            NotificationCenter.default.post(name: .cantRefresh, object: statusCode)
            print("리프레시 토큰 다이") // 목록에 많이 쌓인거?
    
            requestsToRetry.removeAll()
            completion(.doNotRetry)
            
        default:
            print(request)
            print("예외",statusCode)

            completion(.doNotRetry)
        
        }
    }
}

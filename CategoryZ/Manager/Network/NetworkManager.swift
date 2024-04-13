//
//  NetworkManager.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation
import Alamofire
import RxSwift

protocol NetworkType {
    // 서버로 부터 데이터를 불러주는 함수입니다.
    static func fetchNetwork<T:Decodable>(model: T.Type, router: NetworkRouter) -> Single<Result<T, NetworkError>>
    
    // 서버로 데이터를 보내는 함수입니다.
    
    
}

struct NetworkManager {
    
    // 서버로부터 데이터 받을시
    typealias FetchType<T:Decodable> = Single<Result<T, NetworkError>>
    
    // 서버로부터 데이터 보낼시
    typealias SendType<T:Encodable> = Single<Result<Void, NetworkError>>
    
}

extension NetworkManager {
    
    // MARK: 요청시 해당 함수를 사용. 각각의 모델과 라우터를 잘 지정
    static func fetchNetwork<T:Decodable>(model: T.Type, router: NetworkRouter) -> FetchType<T> {
        
        return FetchType.create { single in
            do {
                let urlRequest = try router.asURLRequest()
                print(urlRequest)
                fetchNetwork(urlRequest, model) { result in
                    switch result {
                    case .success(let success):
                        
                        single(.success(.success(success)))
                    case .failure(let failure):
                        print(failure.responseCode)
                        if let stateCode = failure.responseCode {
                            if let commonCode = NetworkRouter.commonTest(status: stateCode) {
                                single(.success(.failure(commonCode)))
                            }
                            
                            single(.success(.failure(router.errorCase(stateCode, failure.localizedDescription))))
                        }
                        single(.success(.failure(.unknownError)))
                    }
                }
            } catch {
                single(.success(.failure(.failMakeURLRequest)))
            }
            return Disposables.create()
        }
    }
    
    /// 알라모 파이어의 요청 로직입니다.
    private static func fetchNetwork<T:Decodable>(_ urlRequest: URLRequest, _ data: T.Type, handler: @escaping (Result<T, AFError>) -> Void ) {
        AF.request(urlRequest, interceptor: AccessTokkenAdapter())
            .validate(statusCode: 200 ..< 300)
            .responseDecodable(of: data) { response in
                switch response.result {
                case .success(let success):
                    handler(.success(success))
                case .failure(let failure):
                    handler(.failure(failure))
                }
            }
        // 테스트용
//        AF.request(urlRequest, interceptor: AccessTokkenAdapter())
//            .validate(statusCode: 200 ..< 300)
//            .responseString { response in
//                print(response)
//            }
    }
    
    // NetworkManager에서 이미지 처리
    static func uploadImages<T:Decodable>(model: T.Type, router: PostsRouter, images: [Data]) -> FetchType<T>  {
    
        return FetchType.create { single in
            
            let version = router.version
            let path = version + router.path
            
            guard case .imageUpload = router,
                  let url = router.baseUrl?.appendingPathComponent(path, conformingTo: .url) else {
                single(.success(.failure(.failMakeURLRequest)))
                return Disposables.create()
            }
            
            AF.upload(multipartFormData: { multiPartFromData in
                for (index, imageData ) in images.enumerated() {
                    multiPartFromData.append(
                        imageData,
                        withName: "files",
                        fileName: "CategoryZ_\(index).jpg",
                        mimeType: "image/jpg"
                    )
                }
            }, to: url, method: .post, headers: HTTPHeaders(router.headers), interceptor:  AccessTokkenAdapter()).responseDecodable(of: model) { response in
                switch response.result {
                case .success(let success):
                    return single(.success(.success(success)))
                case .failure(let fails):
                    if let stateCode = fails.responseCode {
                        if let commonCode = NetworkRouter.commonTest(status: stateCode) {
                            single(.success(.failure(commonCode)))
                        }
                        
                        single(.success(.failure(router.errorCase(stateCode, fails.localizedDescription))))
                    }
                    single(.success(.failure(.unknownError)))
                }
            }
            
            return Disposables.create()
        }
        
    }
    
}

// Request Refresh
extension NetworkManager {
    
    static func requestRefreshTokken( complite: @escaping( (Result<RefreshModel, RefreshError>) -> Void)) {
        
        guard let accessToken = TokenStorage.shared.accessToken,
              let refreshToken = TokenStorage.shared.refreshToken else {
            complite(.failure(.cantReadTokken))
            return
        }
        let urlRequest = try? authenticationRouter.refreshTokken(access: accessToken, Refresh: refreshToken).asURLRequest()
        
        guard let urlRequest else {
            print("테스트")
            complite(.failure(.reqeustFail))
            return
        }
        
        fetchNetwork(urlRequest, RefreshModel.self) { result in
            switch result {
            case .success(let success):
                complite(.success(success))
            case .failure(_):
                complite(.failure(.reqeustFail))
            }
        }
    }
}

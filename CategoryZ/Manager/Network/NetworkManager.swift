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
    
    // 서버로부터 데이터 받을시 + 보낼시 통합
    typealias FetchType<T:Decodable> = Single<Result<T, NetworkError>>
    // 받아올 모델은 없을시
    typealias NoneModelFetchType = Single<Result<Void,NetworkError>>
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
        
    }
    
    /// 모델이 필요없는경우에는 이것을 사용해야 합니다.
    private static func fetchNetwork(_ urlRequest: URLRequest, handler: @escaping (Result<Void, AFError>) -> Void) {
        AF.request(urlRequest, interceptor: AccessTokkenAdapter())
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success:
                    handler(.success(()))
                case .failure(let error):
                    handler(.failure(error))
                }
            }
    }
    
    // NetworkManager에서 이미지 처리
    static func uploadImages<T:Decodable>(model: T.Type, router: PostsRouter, images: [Data]) -> FetchType<T>  {
    
        return FetchType.create { single in
            
            let version = router.version
            let path = version + router.path
            
            guard let baseUrl = URL(string: APIKey.baseURL.rawValue) else {
                single(.success(.failure(.failMakeURLRequest)))
                return Disposables.create()
            }
            
            guard case .imageUpload = router else {
                single(.success(.failure(.failMakeURLRequest)))
                return Disposables.create()
            }
            
            let url = baseUrl.appendingPathComponent(path, conformingTo: .url)
            
            AF.upload(multipartFormData: { multiPartFromData in
                for (index, imageData ) in images.enumerated() {
                    multiPartFromData.append(
                        imageData,
                        withName: "files",
                        fileName: "CategoryZ_\(index).jpeg",
                        mimeType: "image/jpeg"
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
    
    static func uploadChatImages<T:Decodable>(model: T.Type, router: ChatRouter, images: [Data]) -> FetchType<T>  {
        
        return FetchType.create { single in
            
            let version = router.version
            let path = version + router.path
            
            guard let baseUrl = URL(string: APIKey.baseURL.rawValue) else {
                single(.success(.failure(.failMakeURLRequest)))
                return Disposables.create()
            }
            
            guard case .chatingImageUpload = router else {
                single(.success(.failure(.failMakeURLRequest)))
                return Disposables.create()
            }
            
            let url = baseUrl.appendingPathComponent(path, conformingTo: .url)
            
            AF.upload(multipartFormData: { multiPartFromData in
                for (index, imageData ) in images.enumerated() {
                    multiPartFromData.append(
                        imageData,
                        withName: "files",
                        fileName: "CategoryZ_\(index).jpeg",
                        mimeType: "image/jpeg"
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

// NoneModelRequest
extension NetworkManager {
    
    static func noneModelRequest(router: NetworkRouter) -> NoneModelFetchType {
        return NoneModelFetchType.create { single in
            do {
                let urlRequest = try router.asURLRequest()
                print(urlRequest)
                fetchNetwork(urlRequest) { result in
                    switch result {
                    case .success(let success):
                        single(.success(.success(success)))
                    case .failure(let failure):
                        
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
    
}


extension NetworkManager {
    
    static func profileModify<T:Decodable>(type: T.Type, router:ProfileRouter, model:ProfileModifyIn) ->  FetchType<T> {
        
        return FetchType.create { single in
            
            let version = router.version
            let path = version + router.path
            
            guard let baseUrl = URL(string: APIKey.baseURL.rawValue) else {
                single(.success(.failure(.failMakeURLRequest)))
                return Disposables.create()
            }
            
            guard case .profileMeModify = router else {
                single(.success(.failure(.failMakeURLRequest)))
                return Disposables.create()
            }
            
            let url = baseUrl.appendingPathComponent(path, conformingTo: .url)
            
            AF.upload(multipartFormData: { multipartFromData in
                
                if let nick = model.nick?.data(using: .utf8) {
                    multipartFromData.append(nick, withName: "nick")
                }
                if let phoneNum = model.phoneNum?.data(using: .utf8) {
                    multipartFromData.append(phoneNum, withName: "phoneNum")
                }
                if let profile = model.profile {
                    print("여기가 100퍼다 : \(profile)")
                    multipartFromData.append(
                        profile,
                        withName: "profile",
                        fileName: "CategoryZ_profile.jpeg",
                        mimeType: "image/jpeg"
                    )
                }
            }, to: url, method: router.method, headers: HTTPHeaders(router.headers), interceptor: AccessTokkenAdapter())
            .responseDecodable(of: type) { response in
                switch response.result {
                case .success(let success):
                    print(success)
                    single(.success(.success(success)))
                case .failure(let failure):
                    
                    if let stateCode = failure.responseCode {
                        if let commonCode = NetworkRouter.commonTest(status: stateCode) {
                            single(.success(.failure(commonCode)))
                        }
                        
                        single(.success(.failure(router.errorCase(stateCode, failure.localizedDescription))))
                    }
                    single(.success(.failure(.unknownError)))
                }
            }
            return Disposables.create()
        }
    }
}

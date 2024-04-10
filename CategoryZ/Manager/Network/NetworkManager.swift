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
                fetchNetwork(urlRequest, model) { result in
                    switch result {
                    case .success(let success):
                        single(.success(.success(success)))
                    case .failure(let failure):
                        
                        if let stateCode = failure.responseCode {
                            if let commonCode = router.commonTest(status: stateCode) {
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
        AF.request(urlRequest)
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
}



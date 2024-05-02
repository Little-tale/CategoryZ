//
//  paymentsRouter.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import Foundation
import Alamofire

enum PaymentsRouter {
    case validation(paymentsQeury: PaymentsModel)
}

extension PaymentsRouter: TargetType {
 
    var method: Alamofire.HTTPMethod {
        switch self {
        case .validation:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .validation:
            return PathRouter.payments.path + "/validation"
        }
    }
    
    var parametters: Alamofire.Parameters? {
        switch self {
        case .validation:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .validation:
            return [ 
                NetHTTPHeader.contentType.rawValue :
                        NetHTTPHeader.json.rawValue,
                NetHTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue
            ]
        
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .validation:
            return nil
        }
    }
    
    var version: String {
        switch self {
        case .validation:
            return "v1/"
        }
    }
    
    var body: Data? {
        switch self {
        case .validation(let paymentsQeury):
            return NetworkRouter.jsEncoding(paymentsQeury)
        }
    }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError {
        switch self {
        case .validation:
            return .paymentsValidError(statusCode: errorCode, description: description)
        }
    }
}

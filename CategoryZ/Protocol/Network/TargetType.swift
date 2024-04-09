//
//  TargetType.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Alamofire
import Foundation

protocol TargetType: URLRequestConvertible {
    
    var baseUrl: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parametters: Parameters? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    
    //func errorCase(_ errorCode: Int) -> NetworkErrorCase
}

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
    
    var headers: [String: String] { get }
    
    var queryItems: [URLQueryItem]? { get }
    
    var body: Data? { get }
    
    //func errorCase(_ errorCode: Int) -> NetworkErrorCase
}


extension TargetType {
    
    func asURLRequest() throws -> URLRequest {
        
        let urlString = baseUrl.appendingPathComponent(path, conformingTo: .url)
        
        var urlComponents = URLComponents(url: urlString, resolvingAgainstBaseURL: false)!
        
        urlComponents.queryItems = queryItems
        
        guard let lastURL = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        do {
            var urlRequst = try URLRequest(url: lastURL, method: method, headers: HTTPHeaders(headers))
            
            urlRequst.httpBody = body
            
            do {
                return try URLEncoding.default.encode(urlRequst, with: parametters)
            } catch {
                throw URLError(.cannotDecodeContentData)
            }
        } catch {
            throw URLError(.badURL)
        }
    }

    
}

//
//  TargetType.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Alamofire
import Foundation

protocol TargetType: URLRequestConvertible {
    
    var method: HTTPMethod { get }
    
    var path: String { get }
    
    var parametters: Parameters? { get }
    
    var headers: [String: String] { get }
    
    var queryItems: [URLQueryItem]? { get }
    
    var version: String { get }
    
    var body: Data? { get }
    
    var multipart: MultipartFormData { get }
    
    func errorCase(_ errorCode: Int, _ description: String) -> NetworkError

}



extension TargetType {
    
    func asURLRequest() throws -> URLRequest {
        let baseUrl = URL(string: APIKey.baseURL.rawValue)
        guard let baseUrl else { throw URLError(.badURL) }
        
        let lastPath = version + path
        
        let urlString = baseUrl.appendingPathComponent(lastPath, conformingTo: .url)
        
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

    
    var multipart: MultipartFormData {
        return MultipartFormData()
    }
    
}

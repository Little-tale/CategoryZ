//
//  KingFisherNet.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/16/24.
//

import Kingfisher
import Foundation


final class KingFisherNet: ImageDownloadRequestModifier {
    
    private 
    let baseURL = APIKey.baseURL.rawValue
    
    private
    let version = "/v1/"
    
    func modified(for request: URLRequest) -> URLRequest? {
        
        guard let accessTokken = TokenStorage.shared.accessToken else {
            return nil
        }
        var components = URLComponents(string: baseURL)
        
        if #available(iOS 16.0, *) {
            components?.path = version + (request.url?.path() ?? "")
        } else {
            components?.path = version + (request.url?.path ?? "")
        }
        
        guard let url = components?.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue(accessTokken, forHTTPHeaderField: NetHTTPHeader.authorization.rawValue)
        
        urlRequest.addValue(APIKey.sesacKey.rawValue, forHTTPHeaderField: NetHTTPHeader.sesacKey.rawValue)
        
        return urlRequest
    }
}

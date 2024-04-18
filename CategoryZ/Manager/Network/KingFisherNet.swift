//
//  KingFisherNet.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/16/24.
//

import Kingfisher
import Foundation


class KingFisherNet: ImageDownloadRequestModifier {
    
    private 
    let baseURL = APIKey.baseURL.rawValue
    
    private
    let version = "/v1/"
    
    func modified(for request: URLRequest) -> URLRequest? {
    
        let reUrl = baseURL + version + request.description
        
        guard let accessTokken = TokenStorage.shared.accessToken else {
            return nil
        }
        
        guard let url = URL(string: reUrl)else {
            return nil
        }
        
        var urlReqest = URLRequest(url: url)

        urlReqest.addValue(accessTokken, forHTTPHeaderField: NetHTTPHeader.authorization.rawValue)
        urlReqest.addValue(APIKey.sesacKey.rawValue, forHTTPHeaderField: NetHTTPHeader.sesacKey.rawValue)
        return urlReqest
    }
}

//
//  KingFisherRequset.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/18/24.
//

import Foundation
import Kingfisher

final class KingFisherRequset: ImageDownloadRequestModifier {
    
    func modified(for request: URLRequest) -> URLRequest? {
        guard let accessTokken = TokenStorage.shared.accessToken else {
            return nil
        }
        var request = request
        request.addValue(accessTokken, forHTTPHeaderField: NetHTTPHeader.authorization.rawValue)
        request.addValue(APIKey.sesacKey.rawValue, forHTTPHeaderField: NetHTTPHeader.sesacKey.rawValue)
        return request
    }
}

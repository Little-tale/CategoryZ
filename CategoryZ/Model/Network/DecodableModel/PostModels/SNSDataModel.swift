//
//  SNSDataModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation




// SNS 모델
final class SNSDataModel: Decodable, Equatable, Hashable {
    
    let postId: String
    let productId: String
    let title: String
    let content: String
    let content2: String
    let content3: String
    let createdAt: String
    let creator: Creator
    let files: [String]
    var likes: [String]
    let hashTags: [String]
    var comments: [CommentsModel]
    var currentRow = 0
    var animated: Bool = false
    var currentIamgeAt = 0 
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case productId = "product_id"
        case title
        case content2
        case content3
        case content
        case createdAt = "createdAt"
        case creator
        case files
        case likes
        case hashTags
        case comments
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.productId = try container.decodeIfPresent(String.self, forKey: .productId) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.content2 = try container.decodeIfPresent(String.self, forKey: .content2) ?? ""
        self.content3 = try container.decodeIfPresent(String.self, forKey: .content3) ?? ""
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(Creator.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.likes = try container.decode([String].self, forKey: .likes)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        
        self.comments = try container.decode([CommentsModel].self, forKey: .comments)
    }
    
    func changeLikeModel(_ userID: String, likeBool: Bool) {
        if likeBool {
            likes.append(userID)
        } else {
            if let index = likes.firstIndex(of: userID) {
                likes.remove(at: index)
            }
        }
        
    }
    
    static func == (lhs: SNSDataModel, rhs: SNSDataModel) -> Bool {
        if lhs.postId == rhs.postId {
            return true
        }
        return false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(postId)
    }
}

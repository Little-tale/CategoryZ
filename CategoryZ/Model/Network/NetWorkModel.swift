//
//  NetWorkModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/9/24.
//

import Foundation

/// 로그인 모델
struct LoginModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
}
/// 회원가입 모델
struct JoinModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let phoneNum: String
    
    enum CodingKeys: CodingKey {
        case user_id
        case email
        case nick
        case phoneNum
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.email = try container.decode(String.self, forKey: .email)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.phoneNum = try container.decodeIfPresent(String.self, forKey: .phoneNum) ?? ""
    }
    
}

/// 이메일 중복 결과 모델
struct EmailVaildModel: Decodable {
    let message: String
}

/// 리프레시
struct RefreshModel: Decodable {
    let accessToken: String
}

/// 삭제된 유저 모델
struct UserWithDraw: Decodable {
    let user_id: String
    let email: String
    let nick: String
}


/// 이미지 데이터 모델
struct ImageDataModel: Decodable {
    let files: [String]
}


///MARK:  포스트 데이터 모델
struct SNSMainModel: Decodable {
    let data: [SNSDataModel]
    let nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

// MARK: 포스트 모델
struct PostModel: Decodable {
    let postID, title, content: String
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes, comments: [String]

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case title, content, createdAt, creator, files, likes, comments
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postID = try container.decodeIfPresent(String.self, forKey: .postID) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title)  ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content)  ?? ""
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(Creator.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.likes = try container.decode([String].self, forKey: .likes)
        self.comments = try container.decode([String].self, forKey: .comments)
    }
}

// 포스트 읽기 기본 모델
struct PostReadMainModel: Decodable {
    let data: [SNSDataModel]
    let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}
// SNS 모델
final
class SNSDataModel: Decodable, Equatable, Hashable {
    
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




/// 댓글 모델
class CommentsModel: Decodable {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: Creator
    
    var postId = ""
    var currentRow = 0
    var isUserMe = false
    
    enum CodingKeys:String, CodingKey {
        case commentID = "comment_id"
        case content
        case createdAt
        case creator
    }
}

// 만든이
final class Creator: Decodable , Equatable{

    let userID, nick: String // 유저이름 , 유저 아이디
    let profileImage: String? // 프로필 이미지들
    
    var isFollow = false
    
    let uuid = UUID()
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
    }
    
    static func == (lhs: Creator, rhs: Creator) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    init(userID: String, nick: String, profileImage: String?, isFollow: Bool = false) {
        self.userID = userID
        self.nick = nick
        self.profileImage = profileImage
        self.isFollow = isFollow
    }
}



/// 팔로우 모델
struct FollowModel: Decodable {
    let nick: String // 이름
    let opponentNick: String // 상대 이름
    let followingStatus: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case nick
        case opponentNick = "opponent_nick"
        case followingStatus = "following_status"
    }
}


// 프로필 모델
struct ProfileModel: Decodable {
    let userID: String
    let email: String
    let nick: String
    let phoneNum: String
    let followers, following: [Creator]
    let profileImage: String
    let posts: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nick, profileImage, followers, following, posts
        case phoneNum
    }
    
    init() {
        self.userID = ""
        self.email = ""
        self.nick = ""
        self.phoneNum = ""
        self.followers = []
        self.following = []
        self.profileImage = ""
        self.posts = []
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
        self.followers = try container.decode([Creator].self, forKey: .followers)
        self.following = try container.decode([Creator].self, forKey: .following)
        self.posts = try container.decode([String].self, forKey: .posts)
        self.phoneNum = try container.decodeIfPresent(String.self, forKey: .phoneNum) ?? ""
    }
}




struct ProfileModifyIn: Decodable {
    var nick: String?
    var phoneNum: String?
    var birthDay: String?
    var profile: Data?
    
    
    init(nick: String? = nil, phoneNum: String? = nil, birthDay: String? = nil, profile: Data? = nil) {
        self.nick = nick
        self.phoneNum = phoneNum
        self.birthDay = birthDay
        self.profile = profile
    }
    
}

//
//  ProfileModifyIn.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/5/24.
//

import Foundation

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

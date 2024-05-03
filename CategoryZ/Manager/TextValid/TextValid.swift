//
//  TextValid.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/11/24.
//

import Foundation


struct TextValid {
    
    // MARK: 이메일 텍스트 검사
    func EmailTextValid(_ text: String) -> EmailTextValid {
        
        if text.isEmpty {
            return .isEmpty
        }
        if text.count < 10 {
            return .minCount
        }
        
        if  RegularExpressionManager.email.matchesPattern(text) == .match {
            return .match
        } else {
            return .noMatch
        }
        
       
    }
    
    func passwordVaild(_ text: String) -> textValidation {
        
        if text.isEmpty {
            return .isEmpty
        }
        if text.count < 6 {
            return .minCount
        }
        
        return .match
    }
    
    func nickNameVaild(_ text: String) -> textValidation {
        
        if text.isEmpty {
            return .isEmpty
        }
        if text.count < 3 {
            return .minCount
        }
        
        return RegularExpressionManager.nickName.matchesPattern(text)
    }
    
    func phoneNumberValid(_ text: String) -> textValidation {
        if text.isEmpty {
            return .isEmpty
        }
        if text.count < 8{
            return .minCount // 각 케이스별 대응을위해...
        }
        
        return RegularExpressionManager.phoneNumber.matchesPattern(text)
    }
    
    func contentTextValid(_ string: String) -> Bool {
       
        return RegularExpressionManager.contentText.matchesPatternBool(string)
    }
    
    func commentValid(_ string: String, maxCount: Int) -> Bool {
        
        guard !string.isEmpty else {
            return false
        }
        return RegularExpressionManager.commentText(maxCount: maxCount).matchesPatternBool(string)
    }
}

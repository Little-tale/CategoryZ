//
//  RegularExpressionManager.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/3/24.
//

import Foundation


enum textValidation: String {
    case isEmpty
    case minCount
    case match
    case noMatch
}
enum EmailTextValid: String {
    case isEmpty
    case minCount
    case noMatch
    case match
    case validCurrect
    case duplite
}


enum RegularExpressionManager {
    
    case email
    case password
    case nickName
    case phoneNumber
    case contentText
    case commentText(maxCount: Int)
    case hashTag
    
    var pattern: String {
        
        switch self {
        case .email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        case .password:
            return ""
        case .nickName:
            return "^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\\u1100-\\u11FF\\u3130-\\u318F]+$"
        case .phoneNumber:
            return "^\\d{8,}$"
        case .contentText:
            return "^(?!(.*\n){4,})[\\s\\S]{1,49}$"
        case .commentText(let max) :
            return  "^[^\n]{1,\(max)}$"
        case .hashTag:
            return "#[\\w\\p{L}]+"
        }
    }
    
    
    func matchesPattern(_ string: String) -> textValidation {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            if regex.firstMatch(in: string, options: [], range: range) != nil {
                return .match
            }
            return .noMatch
        } catch {
            print("Invalid regex pattern: \(error.localizedDescription)")
            return .noMatch
        }
    }
    
    
    func matchesPatternBool(_ string: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            if regex.firstMatch(in: string, options: [], range: range) != nil {
                return true
            }
            return false
        } catch {
            print("Invalid regex pattern: \(error.localizedDescription)")
            return false
        }
    }
    
    func matchesResults(_ string: String) -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            return regex.matches(in: string,options:[] , range: range)
        } catch {
            return []
        }
    }
    
}

//
//  TextValid.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/11/24.
//

import Foundation

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


final class TextValid {
    
    // MARK: 이메일 텍스트 검사
    func EmailTextValid(_ text: String) -> EmailTextValid {
        
        if text.isEmpty {
            return .isEmpty
        }
        if text.count < 10 {
            return .minCount
        }
        
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        if matchesPattern(text, pattern: emailPattern) == .match {
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
        //let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            //return matchesPattern(text, pattern: pattern)
    }
    
    func nickNameVaild(_ text: String) -> textValidation {
        
        if text.isEmpty {
            return .isEmpty
        }
        if text.count < 3 {
            return .minCount
        }
        let pattern = "^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\\u1100-\\u11FF\\u3130-\\u318F]+$"
        
        return matchesPattern(text, pattern: pattern)
    }
    
    func phoneNumberValid(_ text: String) -> textValidation {
        if text.isEmpty {
            return .isEmpty
        }
        if text.count < 8{
            return .minCount // 각 케이스별 대응을위해...
        }
        let pattern: String = "^\\d{8,}$"
        return matchesPattern(text, pattern: pattern)
    }
    
    func contentTextValid(_ string: String) -> Bool {
        let pattern = "^(?!(.*\n){4,})[\\s\\S]{1,49}$"
        return matchesPatternBool(string, pattern: pattern)
    }
    
    private func matchesPattern(_ string: String, pattern: String) -> textValidation {
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
    
    private func matchesPatternBool(_ string: String, pattern: String) -> Bool {
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
    
   
    
}

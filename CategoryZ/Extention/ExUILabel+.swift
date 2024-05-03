//
//  ExUILabel+.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/25/24.
//

import UIKit.UILabel


extension UILabel {
    
    func commentStyle(){
        font = JHFont.UIKit.re17
        textColor = JHColor.black
        textAlignment = .left
    }
    
    func asHashTag() {
        if let text{
            let attributeString = NSMutableAttributedString(string: text)
            
            let matches = RegularExpressionManager.hashTag
                .matchesResults(text)
            
            for match in matches {
                attributeString.addAttribute(
                    NSAttributedString.Key.foregroundColor,
                    value: JHColor.point,
                    range: match.range
                )
            }
            
            attributedText = attributeString
        }
    }
}

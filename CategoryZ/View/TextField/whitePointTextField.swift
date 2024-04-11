//
//  whitePointTextField.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/11/24.
//

import UIKit
import TextFieldEffects

final class WhitePointTextField: HoshiTextField {
    
    var deFaultPlaceholderText = ""
    
    init(_ placeholder: String? = nil) {
        super.init(frame: .zero)
        deFaultPlaceholderText = placeholder ?? ""
        design(placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func design(_ placeholderText: String?){
        textColor = .textBlack
        placeholderColor = .systemGray3
        borderActiveColor = .point
        borderInactiveColor = .black
        placeholder = placeholderText
        placeholderFontScale = 1.1
    }
    
    func setDefaultPlaceHolder() {
        placeholder = deFaultPlaceholderText
    }
    
}

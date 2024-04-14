//
//  whitePointTextField.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/11/24.
//

import UIKit
import Then
import SnapKit
import TextFieldEffects

class WhitePointTextField: HoshiTextField {
    
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


final class SecurityPointTextField: UIView {
    
    let hiddenButton = UIButton(frame: .zero).then {
        $0.setBackgroundImage(.init(systemName: "eye.circle.fill"), for: .normal)
        $0.tintColor = .point
    }
    var placeholder : String?
    
    lazy var whitePointTextField = WhitePointTextField(placeholder)
    
    init(_ placeholder: String? = nil) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        setUI()
        setHidden()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI(){
        addSubview(whitePointTextField)
        addSubview(hiddenButton)
        whitePointTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hiddenButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.centerY.equalTo(safeAreaLayoutGuide)
            make.width.equalTo(safeAreaLayoutGuide).dividedBy(10)
            make.height.equalTo(hiddenButton.snp.width)
        }
        whitePointTextField.isSecureTextEntry = true
    }
    
    private func setHidden() {
        hiddenButton.addAction(UIAction(handler: {[weak self] _ in
            guard let self else { return }
            whitePointTextField.isSecureTextEntry.toggle()
        }), for: .touchUpInside)
    }
}

//
//  UserInfoRegVIew.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/11/24.
//

import UIKit
import TextFieldEffects
import SnapKit
import Then

final class UserInfoRegView: RxBaseView {
    
    let nameTextField = WhitePointTextField("사용하실 닉네임을 입력 해주세요")
    let emailTextField = WhitePointTextField("이메일을 입력해 주세요")
    
    let emailValidTextButton = UIButton(frame: .zero).then {
        $0.setTitle("중복검사", for: .normal)
        $0.setTitleColor(.point, for: .normal)
        $0.setTitleColor(.systemGray2, for: .disabled)
        $0.tintColor = .point
    }
    
    let passWordTextField = WhitePointTextField("비밀번호를 입력해 주세요").then {
        $0.isSecureTextEntry = true
    }
    
    let passwordHiddenButton = UIButton(frame: .zero).then {
        $0.setBackgroundImage(.init(systemName: "eye.circle.fill"), for: .normal)
        $0.tintColor = .point
    }
    
    let phoneNumberTextField = WhitePointTextField("전화번호를 입력해 주세요 (선택사항)")
    let successButton = PointButton(title: "가입하기")
    
    
    override func configureHierarchy() {
        addSubview(nameTextField)
        addSubview(emailTextField)
        addSubview(emailValidTextButton)
        addSubview(passWordTextField)
        addSubview(passwordHiddenButton)
        addSubview(phoneNumberTextField)
        addSubview(successButton)
    }
    
    override func configureLayout() {
        nameTextField.snp.makeConstraints {
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
            $0.height.equalTo(50)
        }
        
        emailTextField.snp.makeConstraints {
            $0.horizontalEdges.height.equalTo(nameTextField)
            $0.top.equalTo(nameTextField.snp.bottom).offset(24)
        }
        emailValidTextButton.snp.makeConstraints { make in
            make.centerY.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField).inset(4)
        }
        
        passWordTextField.snp.makeConstraints {
            $0.horizontalEdges.height.equalTo(nameTextField)
            $0.top.equalTo(emailTextField.snp.bottom).offset(24)
        }
        
        passwordHiddenButton.snp.makeConstraints {
            $0.centerY.equalTo(passWordTextField)
            $0.size.equalTo(24)
            $0.trailing.equalTo(passWordTextField).inset(8)
        }
        
        phoneNumberTextField.snp.makeConstraints {
            $0.horizontalEdges.height.equalTo(passWordTextField)
            $0.top.equalTo(passWordTextField.snp.bottom).offset(24)
        }
        successButton.snp.makeConstraints {
            $0.horizontalEdges.height.equalTo(phoneNumberTextField)
            $0.top.equalTo(phoneNumberTextField.snp.bottom).offset(24)
        }
        
    }
    
}

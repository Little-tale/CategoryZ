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
    let passWordTextField = WhitePointTextField("비밀번호를 입력해 주세요")
    let phoneNumberTextField = WhitePointTextField("전화번호를 입력해 주세요 (선택사항)")
    let successButton = PointButton(title: "가입하기")
    
    
    override func configureHierarchy() {
        addSubview(nameTextField)
        addSubview(emailTextField)
        addSubview(passWordTextField)
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
        passWordTextField.snp.makeConstraints {
            $0.horizontalEdges.height.equalTo(nameTextField)
            $0.top.equalTo(emailTextField.snp.bottom).offset(24)
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

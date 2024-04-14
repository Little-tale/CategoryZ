//
//  LoginVIew.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/14/24.
//

import UIKit
import SnapKit
import Then

final class LoginView: BaseView {
    let startMent = UILabel().then {
        $0.text = "시작하기"
        $0.font = JHFont.UIKit.bo24
    }
    
    let imageView = UIImageView().then {
        $0.image = UIImage(resource: .login)
    }
    
    let emailTextField = WhitePointTextField("가입하신 이메일를 입력해주세요")
    let passwordTextFeild = WhitePointTextField("비밀번호를 입력해주세요")
    
    override func configureHierarchy() {
        addSubview(startMent)
        addSubview(imageView)
        addSubview(emailTextField)
        addSubview(passwordTextFeild)
    }
    override func configureLayout() {
        startMent.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(40)
            make.top.equalTo(safeAreaLayoutGuide).offset(14)
        }
        imageView.snp.makeConstraints { make in
            make.size.equalToSuperview().dividedBy(2.5)
            make.bottom.equalTo(emailTextField.snp.top).offset(4)
        }
        emailTextField.snp.makeConstraints { make in
            make.centerY.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(40)
        }
        passwordTextFeild.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(15)
            make.height.horizontalEdges.equalTo(emailTextField)
        }
    }
}

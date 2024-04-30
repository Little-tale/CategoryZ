//
//  CheckedUserView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/30/24.
//

import UIKit
import SnapKit
import Then

final class CheckedUserView: RxBaseView {
    
    let startMent = UILabel().then {
        $0.text = "본인 확인"
        $0.font = JHFont.UIKit.bo30
    }
    
    let imageView = UIImageView(frame: .zero).then {
        $0.image = JHImage.deleteUserSadImage
    }
    
    let emailTextField = WhitePointTextField("가입하신 이메일를 입력해주세요")
    
    let passwordTextFeild = SecurityPointTextField("비밀번호를 입력해주세요")
    
    let loginButton = PointButton(title: "삭제하기")
    
    override func configureHierarchy() {
        addSubview(startMent)
        addSubview(emailTextField)
        addSubview(imageView)
        addSubview(passwordTextFeild)
        addSubview(loginButton)
    }
    override func configureLayout() {
        startMent.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(safeAreaLayoutGuide).offset(14)
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(140)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(emailTextField.snp.top)
                .inset( -16 )
        }
        
        emailTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(passwordTextFeild)
            make.bottom.equalTo(passwordTextFeild.snp.top).inset( -20 )
            make.height.equalTo(passwordTextFeild)
        }
        
        passwordTextFeild.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.centerY.equalTo(safeAreaLayoutGuide).inset(-20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(40)
            make.height.equalTo(60)
        }
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(passwordTextFeild)
            make.top.equalTo(passwordTextFeild.snp.bottom).offset(24)
            make.height.equalTo(passwordTextFeild).multipliedBy(0.8)
        }
    }
}


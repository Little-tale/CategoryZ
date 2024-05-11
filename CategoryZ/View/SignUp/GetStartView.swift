//
//  GetStartView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import UIKit
import SnapKit
import Then
import TextFieldEffects
import Lottie


final class GetStartView: RxBaseView {
    
//    private let imageView = UIImageView().then {
//        $0.image = UIImage.appLogo
//        $0.clipsToBounds = true
//        $0.contentMode = .scaleAspectFit
//    }
    
    let imageView = LottieAnimationView(name: "Welcome").then {
        $0.loopMode = .autoReverse
        $0.contentMode = .scaleAspectFit
    }

    
    private let startLabel = UILabel().then {
        $0.text = "Welcome to CategoryZ"
        $0.font = JHFont.UIKit.bo24
        $0.textAlignment = .center
        $0.textColor = JHColor.black
    }
    
    private let subLabel = UILabel().then {
        $0.text = "여러분들의 추억을 공유해보세요!"
        $0.font = JHFont.UIKit.li20
        $0.textAlignment = .center
        $0.textColor = JHColor.black
    }
    
    let loginButton = PointButton(title: "Log in")
    
    let signUpButton = SignUpButton(title: "Sign Up")
    

    
    override func configureHierarchy() {
        addSubview(imageView)
        addSubview(startLabel)
        addSubview(subLabel)
        addSubview(loginButton)
        addSubview(signUpButton)
    }
    
    
    override func configureLayout() {
        
        imageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(startLabel.snp.top).inset( -24 )
            make.height.equalTo(300)
            make.centerX.equalToSuperview()
        }
        
        startLabel.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }

        
        
        subLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(startLabel)
            make.top.equalTo(startLabel.snp.bottom).offset(8)
        }
        
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(signUpButton)
            make.height.equalTo(signUpButton)
            make.bottom.equalTo(signUpButton.snp.top).inset( -10 )
        }
        
        signUpButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(18)
            make.height.equalTo(50)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
    
}

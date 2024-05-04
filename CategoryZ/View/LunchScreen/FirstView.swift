//
//  FirstView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/16/24.
//

import UIKit
import SnapKit
import Then
import Lottie

final class FirstView: RxBaseView {
   
    let animaionView: LottieAnimationView = .init(name: "Lunning")
        .then { 
            $0.loopMode = .autoReverse
        }
    
    override func configureHierarchy() {
        addSubview(animaionView)
    }
    override func configureLayout() {
        animaionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

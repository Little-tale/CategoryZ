//
//  FirstView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/16/24.
//

import UIKit
import SnapKit
import Then

final class FirstView: RxBaseView {
   
    let imageView = UIImageView().then {
        $0.image = .onboardP
    }
    
    override func configureHierarchy() {
        addSubview(imageView)
    }
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(250)
        }
    }
}

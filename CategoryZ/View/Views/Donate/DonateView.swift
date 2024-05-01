//
//  DonateView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import UIKit
import SnapKit
import Then

final class DonateView: RxBaseView {
    
    let profileImageView = CircleImageView(frame: .zero).then {
        $0.tintColor = JHColor.darkGray
        $0.backgroundColor = JHColor.gray
    }
    let userNameLabel = UILabel().then {
        $0.font = JHFont.UIKit.bo20
        $0.textColor = JHColor.darkGray
    }
    
    let priceLabel = UILabel().then {
        $0.font = JHFont.UIKit.re17
        $0.textColor = JHColor.black
        $0.text = "후원하실 금액을 선택하여 주세요!"
        $0.textAlignment = .center
    }
    
    let pricePicker = UIPickerView(frame: .zero)
    
    let donateButton = PointButton(title: "후원하기")
    
    
    override func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(priceLabel)
        addSubview(pricePicker)
        addSubview(donateButton)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(14)
            make.centerX.equalTo(profileImageView)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(10)
            make.centerX.equalTo(profileImageView)
        }
        
        pricePicker.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.top.equalTo(priceLabel.snp.bottom).offset(14)
            make.height.equalTo(180)
        }
        
        donateButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(pricePicker)
            make.top.equalTo(pricePicker.snp.bottom).offset(12)
            make.height.equalTo(50)
        }
    }
}

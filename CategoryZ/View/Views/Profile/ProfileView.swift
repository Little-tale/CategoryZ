//
//  ProfileView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/22/24.
//

import UIKit
import SnapKit
import Then

/*
 회고 intrinsicContentSize
 */

final class ProfileView: BaseView {
    
    
    let profileImageView = CircleImageView(frame: .zero).then {
        $0.tintColor = JHColor.darkGray
        $0.backgroundColor = JHColor.gray
    }
    let userNameLabel = UILabel().then {
        $0.font = JHFont.UIKit.bo20
        $0.textColor = JHColor.darkGray
    }
    let phoneNumLabel = UILabel().then {
        $0.font = JHFont.UIKit.re17
        $0.textColor = JHColor.darkGray
    }
    override var intrinsicContentSize: CGSize {
        let height = 10 + 100 + 14 + userNameLabel.intrinsicContentSize.height + 4 + phoneNumLabel.intrinsicContentSize.height
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    override func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(phoneNumLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(88)
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(14)
            make.centerX.equalTo(profileImageView)
        }
        phoneNumLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(4)
            make.centerX.equalTo(profileImageView)
        }
    }
}

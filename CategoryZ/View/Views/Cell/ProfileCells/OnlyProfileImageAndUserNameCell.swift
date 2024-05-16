//
//  OnlyProfileImageAndUserNameCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import UIKit
import SnapKit

struct OnlyProfileCellModel {
    let userName: String
    let userImage: String?
}

final class OnlyProfileImageAndUserNameCell: BaseTableViewCell {
    
    let profileImageView = CircleImageView(frame: .zero)
    let userNameLabel = UILabel()
    
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userNameLabel)
    }
    
    func setmodel(_ model: OnlyProfileCellModel) {
        
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(14)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().inset(14)
        }
    }
}

//
//  CommentTableViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/25/24.
//

import UIKit
import SnapKit
import Then

final class CommentTableViewCell: RxBaseTableViewCell {
    
    let userImageView = CircleImageView(frame: .zero).then {
        $0.tintColor = JHColor.black
        $0.backgroundColor = JHColor.gray
    }
    
    let userNameLabel = UILabel().then {
        $0.commentStyle()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
    }
    
    override func configureLayout() {
        userImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(6)
            make.centerY.equalTo(userNameLabel)
            make.size.equalTo(50)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide)
            make.height.greaterThanOrEqualTo(50)
            make.leading.equalTo(userImageView.snp.trailing).offset(8)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
                .inset(6)
        }
    }
}

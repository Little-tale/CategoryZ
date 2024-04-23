//
//  FollowerAndFollwingTableViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa


final class FollowerAndFollwingTableViewCell: RxBaseTableViewCell {
    
    private
    let userImageView = UIImageView(frame: .zero)
    
    private
    let userNameLabel = UILabel()
    
    private
    let isFollowingButton = UIButton()
    
    
    override func configureHierarchy() {
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(isFollowingButton)
    }
    
    override func configureLayout() {
        userImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp.trailing).offset(10)
        }
        isFollowingButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(60)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
                .inset(20)
            make.centerY.equalTo(userImageView)
            
        }
        
    }
}

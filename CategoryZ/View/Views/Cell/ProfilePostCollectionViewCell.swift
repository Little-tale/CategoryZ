//
//  ProfilePostCollectionViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import UIKit
import Then
import SnapKit

final class ProfilePostCollectionViewCell: BaseCollectionViewCell {
    
    let postImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let shadowView = UIView().then {
        $0.backgroundColor = JHColor.black.withAlphaComponent(0.5)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
    }

    let postContentLabel = UILabel().then {
        $0.textColor = JHColor.white
        $0.font = JHFont.UIKit.re14
        $0.numberOfLines = 0
    }
    let postDateLabel = UILabel().then {
        $0.textColor = JHColor.white
        $0.font = JHFont.UIKit.li11
        $0.numberOfLines = 1
    }
    
    override func configureHierarchy() {
        contentView.addSubview(postImageView)
        contentView.addSubview(shadowView)
        
        shadowView.addSubview(postContentLabel)
        shadowView.addSubview(postDateLabel)
        
    }
    override func configureLayout() {
        postImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
        shadowView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(postImageView)
            make.height.equalTo(postImageView).dividedBy(2.7)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.bottom.equalTo(postDateLabel.snp.top).inset( 2 )
            make.top.equalTo(shadowView).inset( 4 )
            make.horizontalEdges.equalTo(shadowView).inset(8)
        }
        postDateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(postContentLabel)
            make.height.equalTo(24)
            make.bottom.equalToSuperview()
        }
    }
}


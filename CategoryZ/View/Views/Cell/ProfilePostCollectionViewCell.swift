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
    
    let postImageView = UIImageView()
    
    
    private let shadowView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.shadowColor = JHColor.point.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
    }

    let postContentLabel = UILabel()
    let postDateLabel = UILabel()
    
    
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
            make.height.equalTo(postImageView.snp.verticalEdges).dividedBy(2)
        }
        postContentLabel.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(shadowView).inset(10)
            make.bottom.equalTo(postContentLabel.snp.top)
        }
        postDateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(postContentLabel)
            make.bottom.equalToSuperview()
        }
    }
    
}

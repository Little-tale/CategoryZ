//
//  AddCollectionViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import UIKit
import SnapKit
import Then

final class AddCollectionViewCell: BaseCollectionViewCell {
    
    private let containView = UIView().then {
        $0.backgroundColor = JHColor.gray
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(systemName: "plus.square.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = JHColor.black
    }
    private let textLabel = UILabel().then {
        $0.text = "추가하기"
        $0.font = JHFont.UIKit.li14
        $0.textColor = JHColor.black
    }
    
    override func configureHierarchy() {
        contentView.addSubview(containView)
        containView.addSubview(imageView)
        containView.addSubview(textLabel)
    }
    
    override func designView() {
        containView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(0.9)
        }
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(0.8)
            $0.width.equalToSuperview().dividedBy(2)
            $0.height.equalTo(imageView.snp.width)
        }
        textLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
    }
}

//
//  CategoryReusableCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit
import Then
import SnapKit

final class CategoryReusableCell: BaseCollectionViewCell {
    
    var identi: String?
    
    private let cellImage = CircleImageView()
    
    private let nameLable = UILabel().then {
        $0.font = JHFont.UIKit.bo12
        $0.textColor = JHColor.black
    }
    
    override func configureHierarchy() {
        contentView.addSubview(cellImage)
        contentView.addSubview(nameLable)
    }
    override func configureLayout() {
        nameLable.snp.makeConstraints { make in
            make.centerX.equalTo(cellImage)
            make.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
        
        cellImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(cellImage.snp.height)
            make.bottom.equalTo(nameLable.snp.top)
        }
    }
    
    func setSection(_ product: ProductID) {
        identi = product.identi
        cellImage.image = product.image
        nameLable.text = product.title
    }
    
    func isSelected(_ bool: Bool) {
        print("값을 전달 받긴함 ",bool)
        cellImage.layer.borderWidth = bool ? 3 : 0
        cellImage.layer.borderColor = bool ? JHColor.point.cgColor : .none
    }
    
}


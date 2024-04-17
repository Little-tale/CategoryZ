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
        $0.font = JHFont.UIKit.bo14
        $0.textColor = .textWhite
    }
    
    override func configureHierarchy() {
        contentView.addSubview(cellImage)
        contentView.addSubview(nameLable)
    }
    override func configureLayout() {
        cellImage.snp.makeConstraints { make in
            make.verticalEdges.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.width.equalTo(cellImage.snp.height)
        }
        nameLable.snp.makeConstraints { make in
            make.center.equalTo(cellImage)
        }
    }
    
    func setSection(_ product: ProductID) {
        identi = product.identi
        cellImage.image = product.image.blurCiMode(radius: 3)
        nameLable.text = product.title
    }
    
    func isSelected(_ bool: Bool) {
        cellImage.layer.borderWidth = bool ? 3 : 0
        cellImage.layer.borderColor = bool ? JHColor.point.cgColor : .none
    }
    
}


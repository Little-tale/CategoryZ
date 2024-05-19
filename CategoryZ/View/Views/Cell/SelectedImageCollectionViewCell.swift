//
//  SelectedImageCollectionViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/19/24.
//

import UIKit
import SnapKit
import Then

final class SelectedImageCollectionViewCell: OnlyImageCollectionViewCell {
    
    
    var selectButtonTap: ((Int) -> Void)?
    
    let selectedButton = UIButton().then {
        $0.backgroundColor = JHColor.gray
        $0.layer.cornerRadius = 20 / 2
        $0.clipsToBounds = true
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        contentView.addSubview(selectedButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        selectedButton.snp.makeConstraints { make in
            make.trailing.equalTo(backgoundImage).inset(6)
            make.top.equalTo(backgoundImage).offset(6)
            make.size.equalTo(20)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedButton.backgroundColor = JHColor.gray
        selectedButton.setTitle("", for: .normal)
    }
    
    func setModel(model: ImageItem) {
        backgoundImage.image = UIImage(data: model.imageData)?.resizingImage(targetSize: CGSize(width: 120, height: 200))
        selectedButton.backgroundColor = model.isSelected ?  JHColor.likeColor : JHColor.gray
    }
    
    override func register() {
        super.register()
        selectedButton.addAction(UIAction(handler: {[weak self] _ in
            guard let self else { return }
            selectButtonTap?(selectedButton.tag)
        }), for: .touchUpInside)
    }
}

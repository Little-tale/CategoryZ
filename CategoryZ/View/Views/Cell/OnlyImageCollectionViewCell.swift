//
//  OnlyImageCollectionViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit
import SnapKit

final class OnlyImageCollectionViewCell: BaseCollectionViewCell {
    
    let backgoundImage = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(backgoundImage)
    }
    override func configureLayout() {
        backgoundImage.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    override func designView() {
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        self.backgroundColor = .black
        self.layer.cornerRadius = 30
        self.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        backgoundImage.image = nil
    }
    
    func settingImageMode(_ mode: ContentMode){
        self.backgoundImage.contentMode = mode
    }
    
    func imageSetting(_ data: Data) {
        backgoundImage.image = UIImage(data: data)?.resizingImage(targetSize: CGSize(width: 80, height: 80))
    }
}

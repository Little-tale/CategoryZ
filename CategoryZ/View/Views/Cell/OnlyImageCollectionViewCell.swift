//
//  OnlyImageCollectionViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit
import SnapKit
 
class OnlyImageCollectionViewCell: BaseCollectionViewCell {
    
    let backgoundImage = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(backgoundImage)
    }
    
    override func configureLayout() {
        backgoundImage.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgoundImage.image = nil
    }
    
    func settingImageMode(_ mode: ContentMode){
        self.backgoundImage.contentMode = mode
    }
    
    func imageSetting(_ data: Data) {
        backgoundImage.image = UIImage(data: data)?.resizingImage(targetSize: CGSize(width: 80, height: 80))
    }
}

//
//  RxOnlyImageCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa

final class OnlyRxImageCollectionViewCell: RxBaseCollectionViewCell {
    
    private
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
        super.prepareForReuse()
        backgoundImage.image = nil
    }
    
    func setModel(_ urlString: String?) {
        let behaiviorModel = BehaviorRelay(value: urlString)
        
        behaiviorModel
            .bind(with: self) { owner, model in
                if let model {
                    owner.backgoundImage.downloadImage(
                        imageUrl: model,
                        resizing: owner.backgoundImage.frame.size
                    )
                } else {
                    owner.backgoundImage.image = JHImage.defaultImage
                }
                
            }
            .disposed(by: disposeBag)
    }
    
}

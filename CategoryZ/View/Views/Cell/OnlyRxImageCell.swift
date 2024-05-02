//
//  OnlyRxImageCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/3/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class OnlyRxImageCollectionViewCell: RxBaseCollectionViewCell {
    
    private
    let backgoundImage = UIImageView()
    private
    let moreImage = UIImageView().then {
        $0.image = JHImage.morePostImage
        $0.contentMode = .scaleAspectFit
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
        $0.isHidden = true
    }
    
    override func configureHierarchy() {
        contentView.addSubview(backgoundImage)
        contentView.addSubview(moreImage)
    }
    override func configureLayout() {
        backgoundImage.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
        moreImage.snp.makeConstraints { make in
            make.width.equalTo(backgoundImage).dividedBy(7)
            make.height.equalTo(moreImage.snp.width)
            make.trailing.equalTo(backgoundImage).inset(4)
            make.top.equalTo(backgoundImage).inset(4)
        }
    }
    override func designView() {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgoundImage.image = nil
    }
    
    func setModel(_ urlString: [String]) {
        let behaiviorModel = BehaviorRelay(value: urlString)
        
        behaiviorModel
            .bind(with: self) { owner, model in
                if let model = model.first {
                    owner.backgoundImage.downloadImage(
                        imageUrl: model,
                        resizing: owner.backgoundImage.frame.size
                    )
                } else {
                    owner.backgoundImage.image = JHImage.defaultImage
                }
                
                owner.moreImage.isHidden = model.count > 1 ? false : true
            
            }
            .disposed(by: disposeBag)
    }
    
}

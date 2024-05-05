//
//  ProfilePostCollectionViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class ProfilePostCollectionViewCell: RxBaseCollectionViewCell {
    
    let postImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
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
    

    func setModel(_ model: SNSDataModel) {
        subscribe(model)
    }
    private
    func subscribe(_ model: SNSDataModel) {
        let behaiviorModel = BehaviorRelay(value: model)
        
        behaiviorModel
            .distinctUntilChanged()
            .bind(with: self) { owner, model in
                if let url = model.files.first {
                    owner.postImageView.downloadImage(imageUrl: url, resizing: owner.postImageView.frame.size)
                }
                owner.postContentLabel.text = model.content
                owner.postDateLabel.text = DateManager.shared.differenceDateString(model.createdAt)
                owner.moreImage.isHidden = model.files.count > 1 ? false : true
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        contentView.addSubview(postImageView)
        contentView.addSubview(shadowView)
        shadowView.addSubview(postContentLabel)
        shadowView.addSubview(postDateLabel)
        contentView.addSubview(moreImage)
    }
    override func configureLayout() {
        postImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(postImageView)
            make.height.equalTo(postImageView).dividedBy(2.7)
        }
        moreImage.snp.makeConstraints { make in
            make.size.equalToSuperview().dividedBy(7)
            make.trailing.equalToSuperview().inset(4)
            make.top.equalToSuperview().inset(4)
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


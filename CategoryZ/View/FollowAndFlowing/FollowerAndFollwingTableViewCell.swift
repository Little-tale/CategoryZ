//
//  FollowerAndFollwingTableViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Kingfisher

final class FollowerAndFollwingTableViewCell: RxBaseTableViewCell {
    
    private
    let userImageView = CircleImageView(frame: .zero)
    
    private
    let userNameLabel = UILabel()
    
    private
    let isFollowingButton = UIButton().then {
        $0.backgroundColor = JHColor.darkGray
        $0.tintColor = JHColor.black
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    
    override func configureHierarchy() {
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(isFollowingButton)
    }
    
    
    func setModel(_ model: Creator, followType: FollowType) {
        subscribe(model,followType)

    }
    
    private
    func subscribe(_ model: Creator,_ followType: FollowType) {
        let data = Observable.just(model)
            .share()
        
        data.bind(with: self) { owner, creator in
            // print(creator.profileImage)
            if let image = creator.profileImage {
                owner.userImageView.downloadImage(imageUrl: image, resizing: owner.userImageView.frame.size)
            } else {
                owner.userImageView.image = JHImage.defaultImage
            }
            owner.userNameLabel.text = creator.nick
        }
        .disposed(by: disposeBag)
        
        
        data.bind(with: self) { owner, creator in
            var buttonTitle = ""
            switch followType {
            case .follower(let profileType):
                switch profileType {
                case .me:
                    owner.isFollowingButton.isHidden = true
                case .other:
                    buttonTitle = creator.isFollow ? "팔로잉" : "팔로우"
                }
            case .following(let profileType):
                switch profileType {
                case .me:
                    buttonTitle = creator.isFollow ? "팔로잉" : "팔로우"
                case .other:
                    buttonTitle = creator.isFollow ? "팔로잉" : "팔로우"
                }
            }
            owner.isFollowingButton.setTitle(buttonTitle, for: .normal)
        }
        .disposed(by: disposeBag)
        
    }
    
    override func configureLayout() {
        userImageView.snp.makeConstraints { make in
            
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            
            make.size.equalTo(60)
            
            make.bottom.equalToSuperview().inset(20).priority(.high)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp.trailing).offset(10)
        }
        isFollowingButton.snp.makeConstraints { make in
            make.width.equalTo(65)
            make.height.equalTo(30)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
                .inset(20)
            make.centerY.equalTo(userImageView)
            
        }
    }
}

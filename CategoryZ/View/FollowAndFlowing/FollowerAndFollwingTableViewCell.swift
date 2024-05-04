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
    let userImageView = CircleImageView(frame: .zero).then {
        $0.tintColor = JHColor.black
    }
    
    private
    let userNameLabel = UILabel().then {
        $0.font = JHFont.UIKit.bo17
        $0.textColor = JHColor.black
    }
    
    weak var errorCatch: NetworkErrorCatchProtocol?
    
    private
    let isFollowingButton = UIButton().then {
        $0.configuForFollowing()
    }
    
    
    override func configureHierarchy() {
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(isFollowingButton)
    }
    
    private
    let viewModel = FollowerAndFollwingTableViewCellViewModel()
    
    func setModel(_ model: Creator, _ myID: String) {
        subscribe(model, myID)
        
    }
    
    private
    func subscribe(_ model: Creator, _ myID: String) {
        let behaiviorModel = BehaviorRelay(value: model)
        
        let input = FollowerAndFollwingTableViewCellViewModel.Input(
            behaivorModel: behaiviorModel,
            buttonTap: isFollowingButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        behaiviorModel
            .bind(with: self) { owner, creator in
                let title = creator.isFollow ? "팔로잉" : "팔로우"
                owner.isFollowingButton.setTitle(title, for: .normal)
                
                if let image = creator.profileImage {
                    print("이미지 불러오긴함 ",image)
                    owner.userImageView.downloadImage(imageUrl: image, resizing: owner.userImageView.frame.size)
                } else {
                    owner.userImageView.image = JHImage.defaultImage
                }
                
                owner.userNameLabel.text = creator.nick
                owner.isFollowingButton.isHidden = myID == creator.userID
            }
            .disposed(by: disposeBag)
        
        
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch?.errorCatch(error)
            }
            .disposed(by: disposeBag)
        
        output.changedModel
            .drive(behaiviorModel)
            .disposed(by: disposeBag)
        
    }
    
    override func configureLayout() {
        userImageView.snp.makeConstraints { make in
            
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            
            make.top.equalToSuperview().offset(10)
            
            make.size.equalTo(50)
            
            make.bottom.lessThanOrEqualToSuperview().inset(15)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp.trailing).offset(10)
        }
        
        isFollowingButton.snp.makeConstraints { make in
            // make.width.equalTo(65)
            make.height.equalTo(35)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
                .inset(20)
            make.centerY.equalTo(userImageView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.disposeBag = .init()
    }
}

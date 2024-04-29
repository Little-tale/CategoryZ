//
//  ProfileCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/29/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProfileCell: RxBaseCollectionViewCell {
    
    let profileView = ProfileAndFollowView()
    
    weak var errorDelegate: NetworkErrorCatchProtocol?
    
    let leftButton = UIButton().then {
        $0.backgroundColor = JHColor.black
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    let rightButton = UIButton().then {
        $0.backgroundColor = JHColor.black
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    private
    lazy var buttonStackView = UIStackView(arrangedSubviews: [leftButton, rightButton]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    private
    let viewModel = ProfileCellViewModel()
    
    func setModel(profileType: ProfileType) {
        subscribe(profileType: profileType)
    }
    
    private
    func subscribe(profileType: ProfileType) {
        
        // let modelBH = BehaviorRelay(value: model)
        let beProfileType = BehaviorRelay(value: profileType)
        let leftButtonTap = leftButton.rx.tap
        
        let input = ProfileCellViewModel.Input(
            inputProfileType: beProfileType,
            leftButtonTap: leftButtonTap,
            inputUserId: UserIDStorage.shared.userID
        )
        
        let output = viewModel.transform(input)
        
        output.outputProfile
            .drive(with: self) { owner, profileModel in
                // 팔로워수
                owner.profileView.followerCountLabel.text = profileModel.followers.count.asFormatAbbrevation()
                // 이름
                owner.profileView.userNameLabel.text = profileModel.nick
                
                // 팔로잉 숫자
                owner.profileView.followingCountLabel.text = profileModel.following.count.asFormatAbbrevation()
                
                // 포스트 숫자
                owner.profileView.postsCountLabel.text = profileModel.posts.count.asFormatAbbrevation()
                
                // 프로파일 이미지
                if !profileModel.profileImage.isEmpty {
                    owner.profileView.profileImageView.downloadImage(imageUrl: profileModel.profileImage, resizing: CGSize(width: 100, height: 100))
                }
            }
            .disposed(by: disposeBag)
        
        // 버튼 분기점
        beProfileType
            .bind(with: self) { owner, type in
                var leftTitle = ""
                var rightTitle = ""
                switch type {
                case .me:
                    leftTitle = "프로필 수정"
                    rightTitle = "좋아요한 게시글"
                    owner.rightButton.isHidden = false
                case .other:
                    owner.rightButton.isHidden = true
                }
                owner.leftButton.setTitle(leftTitle, for: .normal)
                owner.rightButton.setTitle(rightTitle, for: .normal)
            }
            .disposed(by: disposeBag)
        
        output
            .networkError
            .bind(with: self) { owner, error in
                owner.errorDelegate?.errorCatch(error)
            }
            .disposed(by: disposeBag)
        
        output.followState
            .drive(with: self) { owner, bool in
                switch profileType {
                case .me:
                    break
                case .other:
                    let title = bool ? "팔로잉" : "팔로우"
                    owner.leftButton.setTitle(title, for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    override func configureHierarchy() {
        addSubview(profileView)
        addSubview(buttonStackView)
    }
    
    override func configureLayout() {
        profileView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            // make.height.equalTo(230)
        }
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(2)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(34)
            make.bottom.equalToSuperview()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
}

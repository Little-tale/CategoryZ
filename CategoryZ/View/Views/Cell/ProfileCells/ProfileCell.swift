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
import Then

protocol MoveToProfileModify: NSObject {
    func moveToProfile(_ profileType: ProfileType)
}

protocol MoveToLikePosters: NSObject {
    func moveToLikes(_ profileType: ProfileType)
}

protocol MoveToFollowOrFollower: NSObject {
    
    func moveFollowORFollower(_ followType: MoveFllowOrFollower, creator: [Creator])
}

final class ProfileCell: RxBaseCollectionViewCell {
    
    let profileView = ProfileAndFollowView()
    
    weak var errorDelegate: NetworkErrorCatchProtocol?
    
    weak var moveProfileDelegate: MoveToProfileModify?
    
    weak var moveLikesDelegate: MoveToLikePosters? 
    
    weak var MoveToFollowOrFollower: MoveToFollowOrFollower?
    
    
    
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
        
        var follower: [Creator] = []
        var following: [Creator] = []
        
       
        
        // let modelBH = BehaviorRelay(value: model)
        let beProfileType = BehaviorRelay(value: profileType)
        let leftButtonTap = leftButton.rx.tap
        
        let input = ProfileCellViewModel.Input(
            inputProfileType: beProfileType,
            leftButtonTap: leftButtonTap,
            inputUserId: UserIDStorage.shared.userID
        )
        // 노토피케이션 을 사용한 이유가
        // 현셀 -> 뷰컨 -> 다른 뷰컨-> 셀 에서 정보를 받아와야 하는데 .... ㅠ
        NotificationCenter.default.rx.notification(.chagedProfileInfo)
            .bind { _ in
                beProfileType.accept(profileType)
            }
            .disposed(by: disposeBag)
        
        let output = viewModel.transform(input)
        
        output.outputProfile
            .drive(with: self) { owner, profileModel in
                // 팔로워수
                owner.profileView.followerCountLabel.text = profileModel.followers.count.asFormatAbbrevation()
                
                follower = profileModel.followers
                // 이름
                owner.profileView.userNameLabel.text = profileModel.nick
                
                // 팔로잉 숫자
                owner.profileView.followingCountLabel.text = profileModel.following.count.asFormatAbbrevation()
                
                following = profileModel.following
                
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
        
        leftButtonTap
            .bind(with: self) { owner, _ in
                owner.moveProfileDelegate?.moveToProfile(profileType)
            }
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.moveLikesDelegate?.moveToLikes(profileType)
            }
            .disposed(by: disposeBag)
        
        profileView.followingButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.MoveToFollowOrFollower?.moveFollowORFollower(.follow(profileType), creator: following)
            }
            .disposed(by: disposeBag)
        
        profileView.followerButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.MoveToFollowOrFollower?.moveFollowORFollower(.follower(profileType), creator: follower)
            }
            .disposed(by: disposeBag)
        
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileView)
        contentView.addSubview(buttonStackView)
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
        viewModel.disposeBag = .init()
    }
    
}

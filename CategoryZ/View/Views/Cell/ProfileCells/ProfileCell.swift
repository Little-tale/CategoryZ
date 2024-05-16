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
        var config = UIButton.Configuration.bordered()
        config.baseForegroundColor = JHColor.white
        config.background.backgroundColor = JHColor.black
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        $0.configuration = config
    }
    let rightButton = UIButton().then {
        var config = UIButton.Configuration.bordered()
        config.baseForegroundColor = JHColor.white
        config.background.backgroundColor = JHColor.black
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        $0.configuration = config
    }
    
    private
    lazy var buttonStackView = UIStackView(arrangedSubviews: [leftButton, rightButton]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    
    private
    var viewModel = ProfileCellViewModel()
    
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

                    owner.profileView.profileImageView
                        .downloadImage(
                            imageUrl: profileModel.profileImage,
                            resizeCase: .low,
                            JHImage.defaultImage
                        )
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
                    leftTitle = "프로필 설정"
                    rightTitle = "좋아요한 게시글"
                case .other:
                    leftTitle = ""
                    rightTitle = "채팅"
                }
                owner.setButton(
                    lbt: leftTitle,
                    rbt: rightTitle
                )
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
                    owner.setButton(lbt: title, rbt: nil)
                }
            }
            .disposed(by: disposeBag)
        
        leftButtonTap
            .bind(with: self) { owner, _ in
                owner.moveProfileDelegate?.moveToProfile(profileType)
            }
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .filter({ _ in
                return profileType == .me
            })
            .bind(with: self) { owner, _ in
                owner.moveLikesDelegate?.moveToLikes(profileType)
            }
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .map({ _ in
                return profileType
            })
            .bind(with: self) { owner, profileType in
                guard case .other(let otherUserId) = profileType else {
                    return
                }
                print(otherUserId) // 채팅방 생성에 필요한 유저 아이디
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
    
    private
    func setButton(lbt: String?, rbt: String?) {
        
        if let lbt {
            if #available(iOS 15, *) {
                var attTitle = AttributedString(lbt)
                attTitle.font =  JHFont.UIKit.bo12
                attTitle.foregroundColor = JHColor.white
                    
                leftButton.configurationUpdateHandler = {
                    button in
                    button.configuration?.attributedTitle = attTitle
                }
            } else {
                leftButton.setTitle(lbt, for: .normal)
            }
            
        }
        
        if let rbt{
            if #available(iOS 15, *) {
                var attTitle = AttributedString(rbt)
                attTitle.font =  JHFont.UIKit.bo12
                attTitle.foregroundColor = JHColor.white
                    
                rightButton.configurationUpdateHandler = {
                    button in
                    button.configuration?.attributedTitle = attTitle
                }
            } else {
                rightButton.setTitle(rbt, for: .normal)
            }
        }
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
        viewModel = .init()
    }
    
}

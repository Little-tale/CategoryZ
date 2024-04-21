//
//  UserProfileViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import Kingfisher
/*
 user 별 작성한 포스트 조회,
 user 프로필 조회 섞어야 해
 productId: 가 문제네...
 */

enum ProfileType{
    case me
    case other(otherUserId: String)
}

final class UserProfileViewController: RxHomeBaseViewController<UserProfileView> {
    
    var profileType = ProfileType.me
    
    let viewModel = UserProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let beProfileType = BehaviorRelay(value: profileType)
        
        let input = UserProfileViewModel.Input(
            inputProfileType: beProfileType
        )
        
        
        let output = viewModel.transform(input)
        
        output.outputProfile
            .drive(with: self) { owner, profileModel in
                // 팔로워수
                owner.homeView.profileView.followerCountLabel.text = profileModel.followers.count.asFormatAbbrevation()
                // 이름
                owner.homeView.profileView.userNameLabel.text = profileModel.nick
                
                // 팔로잉 숫자
                owner.homeView.profileView.followingCountLabel.text = profileModel.following.count.asFormatAbbrevation()
                
                // 포스트 숫자
                owner.homeView.profileView.postsCountLabel.text = profileModel.posts.count.asFormatAbbrevation()
                
                // 프로파일 이미지
                if !profileModel.profileImage.isEmpty {
                    owner.homeView.profileView.profileImageView.kf.setImage(with: profileModel.profileImage.asStringURL,placeholder: JHImage.defaultImage , options: [
                        .transition(.fade(1)),
                        .cacheOriginalImage,
                        .requestModifier(
                            KingFisherNet()
                        ),
                    ])
                }
            }
            .disposed(by: disPoseBag)
        
        // 네트워크 에러
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
    }
    
}



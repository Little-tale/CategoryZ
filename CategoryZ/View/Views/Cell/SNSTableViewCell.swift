//
//  SNSCollectionViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit
import Kingfisher
/*
 // 포스트를 받아 오면
 // 키체인에 저장된 UserId 와 비교해
 // 메뉴 버튼을 누르면
 // 다른 아이디면 해당하는 사용자를 팔로우 할건지 말건지 나오는
 // 사용자 페이지 시트를 띄우도록 하자.
 // 자신의 아이디일 경우 수정할건지 말건지 나오는 알렛으로 대처 하자
 */
/*
 일단 버튼 만들러 ㄱㄱ check V
 이미지 스크롤뷰 완료
 뷰컨으로 가서 통신먼저 테스트
 */
final class SNSTableViewCell: RxBaseTableViewCell {
    
    // 이미지 스크롤 뷰 -> 안에 Rx 게심
    lazy var imageScrollView = ScrollImageView(horizonWidth: contentView.frame.width, horizonHeight: contentView.frame.height)
    
    // 크리에이터 이름 라벨
    let userNameLabel = UILabel()
    // 프로필 이미지뷰
    let profileImageView = CircleImageView().then {
        $0.image = JHImage.defaultImage
        $0.tintColor = JHColor.black
    }
    
    // 좋아요 버튼 옆에는 몇명이 했는지..!
    let likeButton = SeletionButton(
        selected: JHImage.likeImageSelected,
        noSelected: JHImage.likeImageDiselected
    )
        .then { $0.tintColor = JHColor.black }
    
    let likeCountLabel = UILabel().then {
        $0.font = JHFont.UIKit.bo14
    }
    
    // 댓글 버튼
    let commentButton = SeletionButton(
        selected: JHImage.messageSelected,
        noSelected: JHImage.messageDiselected
    ).then { $0.tintColor = JHColor.black }
    
    let commentCountLabel = UILabel().then({
        $0.font = JHFont.UIKit.bo14
    })
    // 컨텐트 라벨
    let contentLable = UILabel().then {
        $0.font = JHFont.UIKit.re12
        $0.numberOfLines = 3
    }
    
    // 날짜 라벨인데 (몇일전인지 계산하기)
    let dateLabel = UILabel().then {
        $0.font = JHFont.UIKit.re10
    }

    // 뷰모델
    let viewModel = SNSTableViewModel()
    
    func setModel(_ model: SNSDataModel, _ userId: String, delegate: LikeStateProtocol) {
        
        let model = BehaviorRelay<SNSDataModel> (value: model)
        let userId = BehaviorRelay<String> (value: userId)
        
        viewModel.likeStateProtocol = delegate
        
        let input = SNSTableViewModel
            .Input(
                snsModel: model,
                inputUserId: userId,
                likedButtonTab: likeButton.rx.tap
            )
        
        let output = viewModel.transform(input)
        
        // 좋아요 버튼 상태
        output.isUserLike
            .drive(with: self) { owner, bool in
                owner.likeButton.isSelected = bool
                owner.likeButton.tintColor = bool ? JHColor.likeColor : JHColor.black
            }
            .disposed(by: disposeBag)
        
        // 좋아요 갯수
        output.likeCount
            .drive(likeCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 댓글 갯수
        output.comentsCount
            .drive(commentCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 프로필 이미지 반영
        output.userProfileImage
            .filter({ $0 != nil })
            .drive(with: self) { owner, imageURL in
                let url = URL(string: imageURL!)
                owner.profileImageView.kf.setImage(with: url, options: [.requestModifier(KingFisherRequset())])
            }
            .disposed(by: disposeBag)
        
        // 프로필 이름 반영
        output.profileName
            .drive(userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 이미지들 반영
        output.imageURLStrings
            .drive(with: self) { owner, imageURLs in
                print(imageURLs)
                owner.imageScrollView.setModel(imageURLs)
            }
            .disposed(by: disposeBag)
        
        // 컨텐트 반영
        output.content
            .drive(contentLable.rx.text)
            .disposed(by: disposeBag)
        
        // 지난 시간 반영
        output.diffDate
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(imageScrollView)
        contentView.addSubview(likeButton)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentButton)
        contentView.addSubview(commentCountLabel)
        contentView.addSubview(contentLable)
        contentView.addSubview(dateLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalTo(contentView.safeAreaLayoutGuide).offset(4)
            make.size.equalTo(35)
        }
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(6)
        }
        imageScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.top.equalTo(profileImageView.snp.bottom).offset(4)
            make.height.equalTo(350)
        }
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(imageScrollView.snp.bottom).offset(4)
            make.leading.equalTo(imageScrollView).offset(8)
            make.size.equalTo(24)
        }
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton)
            make.leading.equalTo(likeButton.snp.trailing).offset(4)
        }
        commentButton.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton)
            make.size.equalTo(likeButton)
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(8)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton)
            make.leading.equalTo(commentButton.snp.trailing).offset(4)
        }
        
        contentLable.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(4)
            make.leading.equalTo(likeButton)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLable.snp.bottom)
            make.leading.equalTo(contentLable)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
    }
}

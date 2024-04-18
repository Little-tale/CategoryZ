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
    let imageScrollView = ScrollImageView(frame: .zero)
    // 크리에이터 이름 라벨
    let userNameLabel = UILabel()
    // 프로필 이미지뷰
    let profileImageView = CircleImageView()
    // 좋아요 버튼 옆에는 몇명이 했는지..!
    let likeButton = SeletionButton(
        selected: JHImage.likeImageSelected,
        noSelected: JHImage.likeImageDiselected,
        seletedColor: JHColor.likeColor
    )
    // 댓글 버튼
    let commentButton = SeletionButton(
        selected: JHImage.messageSelected,
        noSelected: JHImage.messageDiselected
    )
    // 컨텐트 라벨
    let contentLable = UILabel().then {
        $0.font = JHFont.UIKit.re12
        $0.numberOfLines = 3
    }
    
    // 날짜 라벨인데 (몇일전인지 계산하기)
    let dateLabel = UILabel().then {
        $0.font = JHFont.UIKit.re10
    }
    
    let viewModel = SNSTableViewModel()
    
    
    func setModel(_ model: SNSDataModel, _ userId: String) {
        let model = PublishRelay<SNSDataModel> ()
        
        let input = SNSTableViewModel
            .Input(
                snsModel: model
            )
        
        let output = viewModel.transform(input)
    }
    
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(imageScrollView)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(contentLable)
        contentView.addSubview(dateLabel)
    }
    // ->
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(4)
            make.size.equalTo(20)
        }
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing)
        }
        imageScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(4)
            make.height.equalTo(140)
        }
        likeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.size.equalTo(14)
            make.top.equalTo(imageScrollView.snp.bottom).offset(4)
        }
        commentButton.snp.makeConstraints { make in
            make.centerY.size.equalTo(likeButton)
            make.leading.equalTo(likeButton.snp.trailing).offset(3)
        }
        contentLable.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLable.snp.bottom)
            make.leading.equalTo(contentLable)
        }
    }
}

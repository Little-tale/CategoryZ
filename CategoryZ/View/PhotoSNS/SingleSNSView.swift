//
//  SingleSNSView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import UIKit
import SnapKit
import Then

final class SingleSNSView: RxBaseView {
    // 이미지 스크롤 뷰
    private let imageScrollView = ScrollImageView().then {
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
    }
    
    // 크리에이터 이름 라벨
    private let userNameLabel = UILabel()
    
    // 프로필 이미지뷰
    private let profileImageView = CircleImageView().then {
        $0.image = JHImage.defaultImage
        $0.tintColor = JHColor.black
    }
    let rightMoreBuntton = UIButton().then {
        $0.setImage(JHImage.moreImage, for: .normal)
        $0.tintColor = JHColor.black
    }
    
    // 좋아요 버튼 옆에는 몇명이 했는지..!
    private let likeButton = SeletionButton(
        selected: JHImage.likeImageSelected,
        noSelected: JHImage.likeImageDiselected
    )
        .then { $0.tintColor = JHColor.likeColor }
    
    private let likeCountLabel = UILabel().then {
        $0.font = JHFont.UIKit.bo14
    }
    
    // 댓글 버튼
    private
    let commentButton = SeletionButton(
        selected: JHImage.messageSelected,
        noSelected: JHImage.messageDiselected
    ).then { $0.tintColor = JHColor.black }
    
    private
    let commentCountLabel = UILabel().then({
        $0.font = JHFont.UIKit.bo14
    })
    // 컨텐트 라벨
    private let contentLable = UILabel().then {
        $0.font = JHFont.UIKit.re12
        $0.numberOfLines = 3
    }
    
    // 날짜 라벨인데 (몇일전인지 계산하기)
    private let dateLabel = UILabel().then {
        $0.font = JHFont.UIKit.re10
    }
    override func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(rightMoreBuntton)
        addSubview(imageScrollView)
        addSubview(likeButton)
        addSubview(likeCountLabel)
        addSubview(commentButton)
        addSubview(commentCountLabel)
        addSubview(contentLable)
        addSubview(dateLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalTo(safeAreaLayoutGuide).offset(12)
            make.size.equalTo(35)
        }
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(6)
        }
        rightMoreBuntton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(18)
            make.centerY.equalTo(profileImageView)
            make.size.equalTo(20)
        }
        imageScrollView.snp.makeConstraints { make in
           
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
            make.height.equalTo(320)
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
            make.bottom.equalTo(safeAreaLayoutGuide).inset(8)
        }
    }
  
}

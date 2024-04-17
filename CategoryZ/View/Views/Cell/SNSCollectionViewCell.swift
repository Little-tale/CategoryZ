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
 */
final class SNSCollectionViewCell: BaseCollectionViewCell {
    
    let disposeBag = DisposeBag()

    // 이미지 스크롤 뷰
    
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
    
    // 날짜 라벨인데 (몇일전인지 계산하기)
    
    
}

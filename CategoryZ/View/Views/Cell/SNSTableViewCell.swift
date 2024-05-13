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

final class SNSTableViewCell: RxBaseTableViewCell {
    
    weak var currentPageDelegate: CurrentPageProtocol?
    
    // 이미지 스크롤 뷰 -> 안에 Rx 게심
    private
    let imageScrollView = ScrollImageView().then {
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
    }
    
    // 크리에이터 이름 라벨
    private
    let userNameLabel = UILabel().then {
        $0.font = JHFont.UIKit.re14
    }
    
    // 프로필 이미지뷰
    private
    let profileImageView = CircleImageView().then {
        $0.tintColor = JHColor.black
    }
    
    let rightMoreBuntton = UIButton().then {
        $0.setImage(JHImage.moreImage, for: .normal)
        $0.tintColor = JHColor.black
    }
    
    // 좋아요 버튼 옆에는 몇명이 했는지..!
    private
    let likeButton = SeletionButton(
        selected: JHImage.likeImageSelected,
        noSelected: JHImage.likeImageDiselected
    ).then { $0.tintColor = JHColor.likeColor }
    
    private
    let likeCountLabel = UILabel().then {
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
    private
    let contentLable = UILabel().then {
        $0.font = JHFont.UIKit.re12
        $0.numberOfLines = 3
        $0.textColor = JHColor.black
    }
    
    // 날짜 라벨인데 (몇일전인지 계산하기)
    private
    let dateLabel = UILabel().then {
        $0.font = JHFont.UIKit.re10
        $0.textColor = JHColor.darkGray
    }

    // 뷰모델
    private 
    var viewModel = SNSTableViewModel()
    
    func setModel(_ model: SNSDataModel, _ userId: String, delegate: LikeStateProtocol) {
        let behModel = BehaviorRelay<SNSDataModel> (value: model)
        let userId = BehaviorRelay<String> (value: userId)
        let currentPage = imageScrollView.currentPageRx.skip(1)
            
        
        print("Current: \(model). \(model.currentIamgeAt)")
        
        imageScrollView.pageController.currentPage = model.currentIamgeAt
        imageScrollView.changedView.accept(model.currentIamgeAt)
        // 좋아요 상태 딜리게이트
        viewModel.likeStateProtocol = delegate
        
        //
        let input = SNSTableViewModel
            .Input(
                snsModel: behModel,
                inputUserId: userId,
                likedButtonTab: likeButton.rx.tap,
                currentPage: currentPage
            )
        // 좋아요 버튼 탭시 토글 (UI 선 반영)
        likeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.likeButton.isSelected.toggle()
            }
            .disposed(by: disposeBag)
        
        let output = viewModel.transform(input)
        
        // 좋아요 버튼 상태
        output.isUserLike
            .drive(with: self) { owner, bool in
                owner.likeButton.isSelected = bool
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
            .drive(with: self) { owner, imageURL in
                print("asd",owner.profileImageView.frame.size)
                if imageURL == nil || imageURL == "" {
                    owner.profileImageView.image = JHImage.defaultImage
                    print("프로필 이미지 XXX ")
                } else {
                
                    owner.profileImageView
                        .downloadImage(
                            imageUrl: imageURL,
                            resizeCase: .low,
                            JHImage.defaultImage
                        )
                    print("프로필 이미지 있데")
                }
            }
            .disposed(by: disposeBag)
        //$0.image = JHImage.defaultImage
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
            .drive(with: self) { owner, text in
                owner.contentLable.text = text
                owner.contentLable.asHashTag()
            }
            .disposed(by: disposeBag)
        
        // 지난 시간 반영
        output.diffDate
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.diffCurrntPage
            .bind(with: self) { owner, model in
                owner.currentPageDelegate?.currentPage(model: model)
            }
            .disposed(by: disposeBag)
        
        // more 버튼 클릭시 뷰컨에 알리기
        rightMoreBuntton.rx
            .tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind { _ in
                print("???")
                NotificationCenter.default.post(
                    name: .selectedMoreButton,
                    object: nil,
                    userInfo: ["SNSDataModel": behModel.value]
                )
            }
            .disposed(by: disposeBag)
        
        // 코멘트 버튼 클릭시 뷰컨에 알리기
        commentButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { _ in
                NotificationCenter.default.post(name: .commentButtonTap, object: nil, userInfo: ["SNSDataModel": model])
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.changedComment)
            .bind(with: self) { owner, notification in
                guard let snsDataModel = notification.userInfo? ["SNSDataModel"] as? SNSDataModel else {
                    print("SNSDataModelCell 변환 실패")
                    return
                }
                print("포스트 아이디: ", model.postId)
                if model.postId == snsDataModel.postId {
                    owner.commentCountLabel.text = String(snsDataModel.comments.count)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(rightMoreBuntton)
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
            make.leading.top.equalTo(contentView.safeAreaLayoutGuide).offset(14)
            make.size.equalTo(30)
        }
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(6)
        }
        rightMoreBuntton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(18)
            make.centerY.equalTo(profileImageView)
            make.size.equalTo(20)
        }
        imageScrollView.snp.makeConstraints { make in
           
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(320)
        }
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(imageScrollView.snp.bottom).offset(8)
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
            make.top.equalTo(likeButton.snp.bottom).offset(6)
            make.leading.equalTo(likeButton)
            make.trailing.equalTo(imageScrollView.snp.trailing)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLable.snp.bottom).offset(2)
            make.leading.equalTo(contentLable)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareList()
    }
    
    private
    func prepareList(){
        profileImageView.image = nil
        viewModel = .init()
        contentLable.textColor = JHColor.black
    }
}

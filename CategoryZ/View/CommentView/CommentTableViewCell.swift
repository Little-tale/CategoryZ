//
//  CommentTableViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/25/24.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class CommentTableViewCell: RxBaseTableViewCell {
    
    
    private
    let userImageView = CircleImageView(frame: .zero).then {
        $0.tintColor = JHColor.black
        $0.backgroundColor = JHColor.gray
        $0.isUserInteractionEnabled = true
    }
    
    private
    let userNameLabel = UILabel().then {
        $0.commentStyle()
        $0.textAlignment = .left
        $0.font = JHFont.UIKit.bo14
    }
    
    private
    let commentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = JHFont.UIKit.re14
        $0.textAlignment = .left
    }
    
    private
    let commentCreatedDate = UILabel().then {
        $0.font = JHFont.UIKit.li11
        $0.textAlignment = .right
    }
    
    func setModel(_ commentsModel: CommentsModel) {
        if let userImage = commentsModel.creator.profileImage {
            userImageView.downloadImage(
                imageUrl: userImage,
                resizing: userImageView.frame.size
            )
        } else {
            userImageView.image = JHImage.defaultImage
        }
        userNameLabel.text = commentsModel.creator.nick
        commentLabel.text = commentsModel.content
        
        
        commentCreatedDate.text =  DateManager.shared.differenceDateString(
            commentsModel.createdAt
        )
        
        let tap = UITapGestureRecognizer()
        userImageView.addGestureRecognizer(tap)
        
        tap.rx.event
            .withUnretained(self)
            .bind {owner, _ in
                print("Tap..! ")
                if let myId = UserIDStorage.shared.userID  {
                    print("Tap.. myId")
                    var userType = ProfileType.me
                    if commentsModel.creator.userID != myId  {
                        
                        userType = .other(otherUserId: commentsModel.creator.userID)
                    }
                    NotificationCenter.default.post(name: .moveToProfileForComment, object: nil, userInfo: [
                        "ProfileType" : userType
                    ])
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(commentCreatedDate)
        contentView.addSubview(commentLabel)
    }
    
    override 
    func configureLayout() {
        userImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(6)
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.size.equalTo(50)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView).offset(4)
            make.leading.equalTo(userImageView.snp.trailing).offset(12)
        }
        commentCreatedDate.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel.snp.trailing).offset(8)
            make.centerY.equalTo(userNameLabel)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(5)
           
            make.leading.equalTo(userNameLabel)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(50)
            make.height.greaterThanOrEqualTo(30)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
}

//
//  CommentTableViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/25/24.
//

import UIKit
import SnapKit
import Then

final class CommentTableViewCell: RxBaseTableViewCell {
    
    
    private
    let userImageView = CircleImageView(frame: .zero).then {
        $0.tintColor = JHColor.black
        $0.backgroundColor = JHColor.gray
    }
    
    private
    let userNameLabel = UILabel().then {
        $0.commentStyle()
        $0.textAlignment = .left
        $0.font = JHFont.UIKit.re17
    }
    
    private
    let commentLabel = UILabel().then {
        $0.numberOfLines = 5
        $0.font = JHFont.UIKit.re14
        $0.textAlignment = .left
    }
    
    private
    let commentCreatedDate = UILabel().then {
        $0.font = JHFont.UIKit.li14
    }
    
    func setModel(_ commentsModel: CommentsModel) {
        if let userImage = commentsModel.creator.profileImage {
            userImageView.downloadImage(
                imageUrl: userImage,
                resizing: userImageView.frame.size
            )
        }
        userNameLabel.text = commentsModel.creator.nick
        commentLabel.text = commentsModel.content
       
        commentCreatedDate.text =  DateManager.shared.differenceDateString(
            commentsModel.createdAt
        )
    }
    
    override func configureHierarchy() {
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(commentLabel)
    }
    
    override func configureLayout() {
        userImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(6)
            make.centerY.equalTo(userNameLabel)
            make.size.equalTo(50)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(26)
            make.leading.equalTo(userImageView.snp.trailing).offset(8)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
                .inset(6)
        }
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(userNameLabel)
            make.height.greaterThanOrEqualTo(30)
            make.bottom.equalToSuperview()
        }
    }
}

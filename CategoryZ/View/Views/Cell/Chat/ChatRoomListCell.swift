//
//  ChatRoomListCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/21/24.
//

import UIKit
import SnapKit
import Then

final class ChatRoomListCell: BaseTableViewCell {
    
    private
    let profileImageView = UIImageView().then {
        $0.image = JHImage.defaultImage
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    private
    let userName = UILabel().then {
        $0.numberOfLines = 1
        $0.font = JHFont.UIKit.bo15
    }
    
    private
    let lastChatString = UILabel().then {
        $0.numberOfLines = 1
        $0.font = JHFont.UIKit.re12
    }
    
    private
    let lastDate = UILabel().then {
        $0.numberOfLines = 1
        $0.font = JHFont.UIKit.re10
    }
    
    private
    let emptyView = UIView().then {
        $0.backgroundColor = JHColor.likeColor
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private
    let ifNewLabel = UILabel().then {
        $0.text = "NEW"
        $0.font = JHFont.UIKit.bo10
        $0.textColor = JHColor.onlyWhite
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userName)
        contentView.addSubview(lastChatString)
        contentView.addSubview(lastDate)
        contentView.addSubview(emptyView)
        emptyView.addSubview(ifNewLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(10)
            make.width.equalTo(profileImageView.snp.height)
            make.leading.equalToSuperview().offset(10)
        }
        userName.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.bottom.equalTo(profileImageView.snp.centerY).inset(4)
            make.width.lessThanOrEqualToSuperview().dividedBy(2)
        }
        lastChatString.snp.makeConstraints { make in
            make.leading.equalTo(userName)
            make.top.equalTo(profileImageView.snp.centerY).offset(4)
            make.width.lessThanOrEqualToSuperview().dividedBy(2)
        }
        lastDate.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(profileImageView)
        }
        emptyView.snp.makeConstraints { make in
            make.trailing.equalTo(lastDate)
            make.bottom.equalTo(lastDate.snp.top).offset( -8 )
        }
        ifNewLabel.snp.makeConstraints { make in
            make.verticalEdges.equalTo(emptyView).inset(5)
            make.horizontalEdges.equalTo(emptyView).inset(6)
        }
    }
}

extension ChatRoomListCell {
    
    func setModel(_ model: ChattingListModel) {
        
        profileImageView.downloadImage(
            imageUrl: model.userProfie,
            resizeCase: .superLow,
            JHImage.defaultImage
        )
        
        lastChatString.text = model.lastChat
        if let date = model.updateAt {
            lastDate.text = DateManager.shared.differenceDateFormatString(date)
        }
        userName.text = model.userName
        ifNewLabel.isHidden = !model.ifNew
    }
    
}

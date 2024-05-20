//
//  ChatLeftRightCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import UIKit
import SnapKit
import Then

final class ChatLeftRightCell: BaseTableViewCell {
    
    private
    let chatBoxImageView = UIImageView()
    
    private
    let profileImageView = CircleImageView().then {
        $0.image = JHImage.defaultImage
        $0.contentMode = .scaleToFill
    }
    
    private
    let contentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.backgroundColor = .clear
        $0.font = JHFont.UIKit.re14
        $0.textAlignment = .center
    }
    
    private
    let dateLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = JHFont.UIKit.re10
    }

    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(chatBoxImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(contentLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        chatBoxImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.trailing.lessThanOrEqualToSuperview().dividedBy(2)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(chatBoxImageView.snp.trailing)
            make.bottom.equalTo(chatBoxImageView)
        }
        contentLabel.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(chatBoxImageView).inset(10)
            make.bottom.equalTo(chatBoxImageView).inset(24)
        }
        
    }
    
    func setModel(model: ChatBoxRealmModel) {
        setContentTypeLayout(model.isMe)
        setBubbleImage(model.isMe)
        
        profileImageView.downloadImage(
            imageUrl: model.userProfileURL,
            resizeCase: .low,
            JHImage.defaultImage
        )
        dateLabel.text = DateManager.shared.differenceDateFormatString(model.createAt)
        contentLabel.text = model.contentText
    }
}

extension ChatLeftRightCell {
    
    private
    func setBubbleImage(_ isMe: Bool) {
        let image = isMe ? JHImage.ChatBubble.me.image : JHImage.ChatBubble.other.image
        let inset =  isMe ? UIEdgeInsets(
            top: 10, left: 10, bottom: 20, right: 50
        ) : UIEdgeInsets(
            top: 10, left: 50, bottom: 20, right: 10
        )
        chatBoxImageView.image = image.resizableImage(withCapInsets: inset, resizingMode: .stretch)
    }
    
    private
    func setContentTypeLayout(_ isMe: Bool) {
        if isMe {
            profileImageView.isHidden = true
            profileImageView.snp.removeConstraints()
            
            chatBoxImageView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().inset(10)
                make.width.lessThanOrEqualToSuperview().dividedBy(2)
                make.trailing.equalToSuperview().inset(20)
            }
            
            dateLabel.snp.remakeConstraints { make in
                make.trailing.equalTo(chatBoxImageView.snp.leading).offset( -10 )
                make.bottom.equalTo(chatBoxImageView)
                    .inset(20)
            }
        } else {
            chatBoxImageView.snp.remakeConstraints{ make in
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().inset(10)
                make.leading.equalTo(profileImageView.snp.trailing).offset(20)
                make.width.lessThanOrEqualToSuperview().dividedBy(2)
            }
            
            profileImageView.snp.remakeConstraints { make in
                make.size.equalTo(40)
                make.bottom.equalToSuperview().inset(10)
                make.leading.equalToSuperview().offset(10)
            }
            
            dateLabel.snp.remakeConstraints { make in
                make.leading.equalTo(chatBoxImageView.snp.trailing).offset(10)
                make.bottom.equalTo(chatBoxImageView).inset(20)
            }
            
            profileImageView.isHidden = false
        }
    }
}

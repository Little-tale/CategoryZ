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
    
    let chatBoxImageView = UIImageView()
    
    let profileImageView = CircleImageView().then {
        $0.image = JHImage.defaultImage
        $0.contentMode = .scaleToFill
    }
    
    let contentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.backgroundColor = .clear
    }

    override func configureHierarchy() {
        contentView.addSubview(chatBoxImageView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(contentLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        chatBoxImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(4)
            make.trailing.lessThanOrEqualToSuperview().inset(10)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(chatBoxImageView).inset(10)
            make.bottom.equalTo(chatBoxImageView).inset(20)
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
        
        contentLabel.text = model.contentText
        contentLabel.backgroundColor = .gray
        chatBoxImageView.backgroundColor = .red
    }
}

extension ChatLeftRightCell {
    
    private
    func setBubbleImage(_ isMe: Bool) {
        let image = isMe ? JHImage.ChatBubble.me.image : JHImage.ChatBubble.other.image
        let inset =  isMe ? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 50) : UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 10)
        chatBoxImageView.image = image.resizableImage(withCapInsets: inset, resizingMode: .stretch)
    }
    
    private
    func setContentTypeLayout(_ isMe: Bool) {
        if isMe {
            
        } else {
            
        }
    }
}

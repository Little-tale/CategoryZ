//
//  ChatOnlyImagesCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/20/24.
//

import UIKit
import SnapKit
import Then

final class ChatOnlyImagesCell: BaseTableViewCell {
    
    private
    let chatBoxImageView = UIImageView()
    
    private
    let imageCollectionTypeView = BlockImageSetView()
    
    private
    let profileImageView = CircleImageView().then {
        $0.image = JHImage.defaultImage
        $0.contentMode = .scaleToFill
    }
    
    private
    let dateLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = JHFont.UIKit.re10
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(chatBoxImageView)
        contentView.addSubview(imageCollectionTypeView)
        contentView.addSubview(dateLabel)
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
//            make.trailing.equalToSuperview().dividedBy(2)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(chatBoxImageView.snp.trailing)
            make.bottom.equalTo(chatBoxImageView)
        }
        imageCollectionTypeView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(chatBoxImageView).inset(10)
            make.width.equalTo(230)
            make.height.equalTo(230)
            make.bottom.equalTo(chatBoxImageView).inset(24)
        }
    }
    
}

extension ChatOnlyImagesCell {
    func setModel(model: ChatBoxRealmModel){
        let imageFiles = Array(model.imageFiles)
        remakeLayoutFor(isMe: model.isMe)
        
        if !model.isMe {
            settingProfile(url: model.userProfileURL)
        }
        print("이미지 갯수 \(imageFiles.count)")
        dateLabel.text = DateManager.shared.differenceDateFormatString(model.createAt)
        
        let height: CGFloat
        
        switch imageFiles.count {
        case 1: height = 230
        case 2, 3: height = 200
        case 4, 5: height = 270
        default: height = 250
        }
        
        imageCollectionTypeView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        imageCollectionTypeView.setModel(imageFiles)
    }
    
    private
    func settingProfile(url: String?) {
        profileImageView.downloadImage(
            imageUrl: url,
            resizeCase: .superLow,
            JHImage.defaultImage
        )
    }
}


extension ChatOnlyImagesCell {
    func remakeLayoutFor(isMe: Bool) {
        if isMe {
            profileImageView.isHidden = true
            profileImageView.snp.removeConstraints()
            
            chatBoxImageView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().inset(10)
                make.trailing.equalToSuperview().inset(20)
//                make.leading.equalToSuperview().dividedBy(2)
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
//                make.trailing.equalToSuperview().dividedBy(2)
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

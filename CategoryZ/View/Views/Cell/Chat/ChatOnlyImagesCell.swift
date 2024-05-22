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
    let emptyView = UIView()
    
    private
    let imageCollectionTypeView = BlockImageSetView()
    
    private
    let debouce = CustomDebouncer(miliSeconds: 40)
    
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
        contentView.addSubview(emptyView)
        contentView.addSubview(imageCollectionTypeView)
        contentView.addSubview(dateLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().offset(10)
        }
        emptyView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
//            make.trailing.equalToSuperview().dividedBy(2)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(emptyView.snp.trailing)
            make.bottom.equalTo(emptyView)
        }
        imageCollectionTypeView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(emptyView).inset(10)
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.bottom.equalTo(emptyView).inset(24)
        }
    }
    
}

extension ChatOnlyImagesCell {
    func setModel(model: ChatBoxRealmModel){
        let imageFiles = Array(model.imageFiles)
        remakeLayoutFor(isMe: model.isMe)
        
        if !model.isMe {
            debouce.setAction { [weak self] in
                guard let self else { return }
                settingProfile(url: model.userProfileURL)
            }
        }
        print("이미지 갯수 \(imageFiles.count)")
        dateLabel.text = DateManager.shared.differenceDateFormatString(model.createAt)
        
        let height: CGFloat
        let width: CGFloat
        switch imageFiles.count {
        case 1: 
            height = 180
            width = 180
        case 2:
            height = 100
            width = 200
        case 3:
            height = 110
            width = 210
        case 4:
            height = 200
            width = 200
        case 5:
            height = 200
            width = 230
        default:
            height = 200
            width = 200
        }
        
        imageCollectionTypeView.snp.updateConstraints { make in
            make.height.equalTo(height)
            make.width.equalTo(width)
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
    
    private
    func remakeLayoutFor(isMe: Bool) {
        if isMe {
            profileImageView.isHidden = true
            profileImageView.snp.removeConstraints()
            
            emptyView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().inset(10)
                make.trailing.equalToSuperview().inset(20)
//                make.leading.equalToSuperview().dividedBy(2)
            }
            
            dateLabel.snp.remakeConstraints { make in
                make.trailing.equalTo(emptyView.snp.leading).offset( -10 )
                make.bottom.equalTo(emptyView)
                    .inset(20)
            }
        } else {
            emptyView.snp.remakeConstraints{ make in
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
                make.leading.equalTo(emptyView.snp.trailing).offset(10)
                make.bottom.equalTo(emptyView).inset(20)
            }
            
            profileImageView.isHidden = false
        }
    }
}

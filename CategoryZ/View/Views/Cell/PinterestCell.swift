//
//  PinterestCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import UIKit
import Then
import RxSwift
import RxCocoa
import SnapKit


final class PinterestCell: RxBaseCollectionViewCell {
    
    let profileImageView = CircleImageView(frame: .zero).then {
        $0.tintColor = JHColor.darkGray
        $0.backgroundColor = JHColor.gray
    }
    let userNameLabel = UILabel().then {
        $0.font = JHFont.UIKit.re12
        $0.textColor = JHColor.darkGray
    }
    
    let postImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }

    let postContentLabel = UILabel().then {
        $0.textColor = JHColor.black
        $0.font = JHFont.UIKit.re14
        $0.numberOfLines = 1
    }
    let postDateLabel = UILabel().then {
        $0.textColor = JHColor.black
        $0.font = JHFont.UIKit.li11
        $0.numberOfLines = 1
    }
    
    
    func setModel(_ data: SNSDataModel) {
        print("데이터 잘만 넘어옴",data )
        subscribe(data)
    }
    
    private
    func subscribe(_ model: SNSDataModel) {
        let behaiviorModel = BehaviorRelay(value: model)
        behaiviorModel
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, model in
                if let url =  model.files.first {
        
                    owner.postImageView
                        .downloadImage(
                            imageUrl: url,
                            resizeCase: .middle,
                            JHImage.defaultImage
                        )
                }
              
                owner.postDateLabel.text = DateManager.shared.differenceDateString(model.createdAt)
                
                owner.profileImageView
                    .downloadImage(
                        imageUrl: model.creator.profileImage,
                        resizeCase: .low,
                        JHImage.defaultImage
                    )
                
                owner.userNameLabel.text = model.creator.nick
                
                owner.postContentLabel.text = model.content
                print(model.content)
            }
            .disposed(by: disposeBag)
       
    }
    
    override func configureHierarchy() {
        contentView.addSubview(postImageView)
        contentView.addSubview(postContentLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(postDateLabel)
    }
    
    override func configureLayout() {
        postImageView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(contentView.safeAreaLayoutGuide)
            make.bottom.equalTo(profileImageView.snp.top)
                .inset( -8 )
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.leading.equalTo(postImageView).offset(2)
            make.bottom.equalTo(postContentLabel.snp.top).inset(-4)
        }
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(4)
            make.trailing.equalTo(postDateLabel.snp.leading).inset(2)
        }
        
        postDateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(24)
            make.centerY.equalTo(profileImageView)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(4)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().inset(4)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.stopDownloadTask()
        disposeBag = .init()
    }
}

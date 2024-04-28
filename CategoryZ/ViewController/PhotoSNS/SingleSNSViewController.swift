//
//  SingleSNSViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SingleSNSViewController: RxHomeBaseViewController<SingleViewRx> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.singleView.rightMoreBuntton.isHidden = true
    }
    
    private
    let viewModel = SingleSNSViewModel()
    
    func setModel(_ SNSData: SNSDataModel) {
        subscribe(SNSData)
    }
    
    private
    func subscribe(_ SNSData: SNSDataModel) {
        
        let setDataBe = BehaviorRelay(value: SNSData)
        
        let input = SingleSNSViewModel.Input(
            setDataBe: setDataBe
        )
        
        homeView.singleView.dateLabel.text = DateManager.shared.differenceDateString(SNSData.createdAt) 
        
        let output = viewModel.transform(input)
        
        output.contents
            .drive(homeView.singleView.contentLable.rx.text)
            .disposed(by: disPoseBag)
        
        output.imageStrings
            .drive(with: self) { owner, strings in
                owner.homeView.singleView.imageScrollView.setModel(strings)
            }
            .disposed(by: disPoseBag)
        
        output.isuserLike
            .drive(with: self) { owner, model in
                owner.homeView.singleView.likeButton.isSelected = model.like_status
            }
            .disposed(by: disPoseBag)
        
        output.likeCount
            .map { String($0) }
            .drive(homeView.singleView.likeCountLabel.rx.text)
            .disposed(by: disPoseBag)
        
        output.messageCount
            .map { String($0) }
            .drive(homeView.singleView.commentCountLabel.rx.text)
            .disposed(by: disPoseBag)
        
        output.profile
            .drive(with: self) { owner, creator in
                owner.homeView.singleView.userNameLabel.text = creator.nick
                owner.homeView.singleView.profileImageView.downloadImage(
                    imageUrl: creator.profileImage,
                    resizing: owner.homeView.singleView.profileImageView.frame.size,
                    JHImage.defaultImage
                )
            }
            .disposed(by: disPoseBag)
        
    }
    
}

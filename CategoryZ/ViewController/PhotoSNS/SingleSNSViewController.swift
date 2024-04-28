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
            setDataBe: setDataBe,
            likeButtonTap: homeView.singleView.likeButton.rx.tap
        )
        
        homeView.singleView.dateLabel.text = DateManager.shared.differenceDateString(SNSData.createdAt) 
        
        let output = viewModel.transform(input)
        
        output.contents
            .drive(homeView.singleView.contentLable.rx.text)
            .disposed(by: disPoseBag)
        
        output.imageStrings
            .distinctUntilChanged()
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
        
        output
            .networkError
            .bind(with: self, onNext: { owner, error in
                owner.errorCatch(error)
            })
            .disposed(by: disPoseBag)
        
        homeView.singleView.commentButton.rx.tap
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let vc = CommentViewController()
                vc.setModel(SNSData)
                let nvc = UINavigationController(rootViewController: vc)
                
                nvc.modalPresentationStyle = .pageSheet
                owner.present(nvc, animated: true)
            }
            .disposed(by: disPoseBag)
        
        NotificationCenter.default.rx.notification(.changedComment)
            .bind(with: self) { owner, notification in
                guard let snsDataModel = notification.userInfo? ["SNSDataModel"] as? SNSDataModel else {
                    print("SNSDataModelCell 변환 실패")
                    return
                }
                print("포스트 아이디: ", SNSData.postId)
                if SNSData.postId == snsDataModel.postId {
                    owner.homeView.singleView.commentCountLabel.text = String(snsDataModel.comments.count)
                }
            }
            .disposed(by: disPoseBag)
        
        settingLikeButton()
    }
    
    
    private
    func settingLikeButton(){
        homeView.singleView.likeButton
            .rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.homeView.singleView.likeButton.isSelected.toggle()
            }
            .disposed(by: disPoseBag)
    }
}

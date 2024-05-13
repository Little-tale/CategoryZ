//
//  SingleSNSViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: 좋아요 한것을 바로 반영 하지 않기로 결정하였으나 대기.
protocol changedModel: AnyObject {
    func ifChange(_ model: SNSDataModel)
}

final class SingleSNSViewController: RxHomeBaseViewController<SingleViewRx> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.singleView.contentLable.asHashTag()
    }
    weak var ifChangeOfLikeDelegate: changedModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default
            .rx
            .notification(.moveToProfileForComment, object: nil)
            .take(until: rx.viewDidDisapear)
            .bind(with: self) { owner, noti in
                guard let profileType =  noti.userInfo? ["ProfileType"] as? ProfileType else {
                    print("ProfileType Fail b")
                    return
                }
                print("Fail? ")
                let vc = UserProfileViewController()
                vc.profileType = profileType
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
    }
    
    private
    let viewModel = SingleSNSViewModel()
    
    func setModel(_ SNSData: SNSDataModel) {
        subscribe(SNSData)
    }
    // 자신의 것만 지원하기에 현재는 이렇게 처리해 놓게습니다.
    func setModel(_ SNSData: SNSDataModel, me: Bool){
        subscribe(SNSData, me: me)
    }
    
    private
    func subscribe(_ SNSData: SNSDataModel, me: Bool? = nil) {
        
        let setDataBe = BehaviorRelay(value: SNSData)
        let moreButtonTap = PublishRelay<SNSDataModel> ()
        let modifyModel = PublishRelay<SNSDataModel> ()
        let deleteModel = PublishRelay<SNSDataModel> ()
        let checkedDeleteModel = PublishRelay<SNSDataModel> ()
        
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
            .bind(with: self) { owner, model in
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
            
                owner.homeView.singleView.profileImageView
                    .downloadImage(
                        imageUrl: creator.profileImage,
                        resizeCase: .low,
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
                    owner.homeView.singleView.commentCountLabel  .text = String(snsDataModel.comments.count)
                }
            }
            .disposed(by: disPoseBag)
        
        output.moreButtonEnabled
            .drive(with: self) { owner, bool in
                owner.homeView.singleView.rightMoreBuntton.isHidden = !bool
                owner.homeView.singleView.rightMoreBuntton.isEnabled = bool
            }
            .disposed(by: disPoseBag)
        
        homeView.singleView.rightMoreBuntton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showActionSheet(title: nil, message: nil, actions: [
                    (title: "프로필보기", handler: { _ in
                        let modalViewCon = MorePageViewController()
                        modalViewCon.setModel(SNSData.creator)
                        
                        modalViewCon.modalPresentationStyle = .pageSheet
                        owner.present(modalViewCon, animated: true)
                    }),
                    (title: "게시글 수정", handler: {_ in
                        modifyModel.accept(SNSData)
                    }),
                    (title: "게시글 삭제", handler: {_ in
                        deleteModel.accept(SNSData)
                    })
                ])
            }
            .disposed(by: disPoseBag)
        
        modifyModel
            .bind(with: self) { owner, model in
                let vc = PostRegViewController()
                vc.ifModifyModel = model
                vc.hidesBottomBarWhenPushed = true
                
                NotificationCenter.default.post(name: .hidesBottomBarWhenPushed, object: nil)
                
                vc.modifyDelegate = self
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
    
        deleteModel
            .bind(with: self) { owner, model in
                owner.showAlert(
                    title: "삭제",
                    message: "삭제하시면 복구하실수 없습니다!",
                    actionTitle: "삭제",
                    { _ in
                        checkedDeleteModel.accept(model)
                    },
                    .default
                )
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

extension SingleSNSViewController: ModifyDelegate {
    
    func mofifyedModel(_ model: SNSDataModel) {
        disPoseBag = DisposeBag()
        ifChangeOfLikeDelegate?.ifChange(model)
        setModel(model)
    }
}

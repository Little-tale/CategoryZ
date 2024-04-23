//
//  MorePageViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then


final class MorePageViewController: RxBaseViewController {
    
    private
    let profileView = ProfileAndFollowView()
    
    private
    let leftButton = UIButton().then {
        $0.backgroundColor = JHColor.black
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    private
    let rightButton = UIButton().then {
        $0.backgroundColor = JHColor.black
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
        $0.setTitle("프로필 이동", for: .normal)
    }
    
    private
    lazy var buttonStackView = UIStackView(arrangedSubviews: [leftButton, rightButton]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    

    // viewModel
    
    let viewModel = SubProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
        }
    }
    
    func setModel(_ model: Creator) {
        guard let userId = UserIDStorage.shared.userID else {
            print("유저 아이디가 감지 되질 않아요 참")
            dismiss(animated: true)
            return
        }
        
        let beModel = BehaviorRelay(value: model)
        let leftButtonTap = leftButton.rx.tap
        let rightButtonTap = rightButton.rx.tap
        
        let input = SubProfileViewModel.Input(
            beCreator: beModel,
            currentUserId: userId,
            leftButtonTap: leftButtonTap
        )
        
        let output = viewModel.transform(input)
        
        output.profileModel
            .drive(with: self) { owner, model in
        
                owner.profileView.followerCountLabel.text = model.followers.count.asFormatAbbrevation()
                
                owner.profileView.followingCountLabel.text = model.following.count.asFormatAbbrevation()
                
                owner.profileView.userNameLabel.text = model.nick
               
                owner.profileView.postsCountLabel.text = model.posts.count.asFormatAbbrevation()
            }
            .disposed(by: disPoseBag)
        
        // ERROR
        output.networkError
            .drive(with: self) { owner, error in
                print("as",error.errorCode)
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        // 팔로잉 팔로우 또는 프로필 수정 반영
        // 만약 팔로잉 팔로우 중 UI반영을 한후 서버의 데이터를 바라보는게 아닌
        // 순수 UI 착시 효과를 주어야 할것같음
        output.currnetFollowState
            .drive(with: self) { owner, type in
                switch type {
                case .follow:
                    owner.leftButton.setTitle("팔로우", for: .normal)
                case .folling:
                    owner.leftButton.setTitle("팔로잉", for: .normal)
                case .modiFyProfile:
                    owner.leftButton.setTitle("프로필 수정", for: .normal)
                }
            }
            .disposed(by: disPoseBag)
        
        output.currentFollowersCount
            .drive(with: self) { owner, value in
                owner.profileView.followerCountLabel.text = value.asFormatAbbrevation()
            }
            .disposed(by: disPoseBag)
         
        // 프로필 이동 클릭시 UX 상 전뷰컨에 알려서 거기서 이동시켜야 될것 같음
        rightButtonTap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .withLatestFrom(output.profileModel)
            .bind(with: self) { owner, model in
                if model.userID == userId {
                    owner.dismiss(animated: true) {
                        NotificationCenter.default.post(name: .moveToProfile, object: nil, userInfo: ["profileUserId": ProfileType.me])
                    }
                } else {
                    owner.dismiss(animated: true) {
                        NotificationCenter.default.post(name: .moveToProfile, object: nil, userInfo: ["profileUserId": ProfileType.other(otherUserId: model.userID)])
                    }
                }
            }
            .disposed(by: disPoseBag)
        
        
        leftButtonTap
            .withLatestFrom(output.currnetFollowState)
            .bind(with: self) { owner, type in
                if case .modiFyProfile = type {
                    owner.dismiss(animated: true) {
                        NotificationCenter.default.post(name: .moveToSettingProfile, object: nil)
                    }
                }
            }
            .disposed(by: disPoseBag)
       
        // 프로필 이미지
        output.profileModel
            .drive(with: self) { owner, model in
                if !model.profileImage.isEmpty {
                    owner.profileView.profileImageView.downloadImage(imageUrl: model.profileImage, resizing: owner.profileView.profileImageView.frame.size)
                }
            }
            .disposed(by: disPoseBag
            )
    }
    
    override func configureHierarchy() {
        view.addSubview(profileView)
        view.addSubview(buttonStackView)

    }
    override func configureLayout() {
        profileView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.height.equalTo(220)
        }
        buttonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(profileView.snp.bottom).offset(10)
        }
    }
}

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
    let profileView = ProfileView()
    
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
            leftButtonTap: leftButtonTap,
            rightButtonTap: rightButtonTap
        )
        
        let output = viewModel.transform(input)
        
        output.profileModel
            .drive(with: self) { owner, model in
                var leftTitle = ""
                var rightTitle = ""
                owner.profileView.followerCountLabel.text = model.followers.count.asFormatAbbrevation()
                
                owner.profileView.followingCountLabel.text = model.following.count.asFormatAbbrevation()
                
                owner.profileView.userNameLabel.text = model.nick
                
                if userId == model.userID {
                    leftTitle = "프로필 수정"
                    
                } else {
                    leftTitle = model.followers.contains(where: { $0.userID == userId }) ? "팔로잉" : "팔로우"
                }
                owner.leftButton.setTitle(leftTitle, for: .normal)
               
            }
            .disposed(by: disPoseBag)
        
        // ERROR
        output.networkError
            .drive(with: self) { owner, error in
                print("as",error.errorCode)
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
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

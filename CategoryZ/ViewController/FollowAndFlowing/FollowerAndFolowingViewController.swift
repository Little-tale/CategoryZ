//
//  FollowerAndFolowingViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import UIKit
import RxSwift
import RxCocoa


enum FollowType {
    case follower
    case following
}
protocol moveProfileDelegate: NSObject {
    func moveProfile(_ model: Creator)
}

final class FollowerAndFolowingViewController: RxHomeBaseViewController<FollowerAndFollowingView> {
    
    private
    let viewModel = FollowerFollowingViewModel()
    
    weak var moveProfileDelegate: moveProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.tableView.rowHeight = UITableView.automaticDimension
        homeView.tableView.estimatedRowHeight = 150
    }
    
    func setModel(_ creator: [Creator], followType: FollowType, isME: ProfileType) {
        navigationSetting(followType)
        subscribe(creator, isMe: isME, followType: followType)
    }

    private
    func subscribe(_ creator: [Creator], isMe: ProfileType,followType: FollowType) {
        dump(creator)
        let myID = UserIDStorage.shared.userID
        guard let myID else {
            errorCatch(.refreshTokkenError(statusCode: 419, description: "ID Error"))
            return
        }
        
        let behivorPersons = BehaviorRelay(value: creator)
        let behaviorRelay = BehaviorRelay(value: isMe)
        
        let input = FollowerFollowingViewModel.Input(
            inputPersons: behivorPersons,
            inputProfileType: behaviorRelay,
            followType: followType,
            inputMyId: myID
        )
        
        rx.viewWillAppear
            .skip(1)
            .bind { _ in
                let value = behaviorRelay.value
                behaviorRelay.accept(value)
            }
            .disposed(by: disPoseBag)
        
        let output = viewModel.transform(input)
        
        // 에러 발생시
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        output.outputOtherUser.drive(homeView.tableView.rx.items(cellIdentifier: FollowerAndFollwingTableViewCell.reusableIdenti, cellType: FollowerAndFollwingTableViewCell.self)) { row, item, cell in
            print("셀입장에서",item.isFollow)
            cell.errorCatch = self
            cell.setModel(item, myID)
        }
        .disposed(by: disPoseBag)
        
        homeView.tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.homeView.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disPoseBag)
        
        homeView.tableView.rx.modelSelected(Creator.self)
            .bind(with: self) { owner, creator in
                guard let userId = UserIDStorage.shared.userID else {
                    owner.errorCatch(
                        .loginError(statusCode: 419, description: "재 로그인 요망"))
                    return
                }
                
                if userId == creator.userID {
                    return
                }
                
                let vc = UserProfileViewController()
                vc.profileType = .other(otherUserId: creator.userID)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
    
    }
    
    private
    func navigationSetting(_ model: FollowType) {
        var title = ""
        switch model {
        case .follower:
            title = "팔로워"
        case .following:
            title = "팔로잉"
        }
        navigationItem.title = title
    }
}
